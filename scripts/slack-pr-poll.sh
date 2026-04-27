#!/usr/bin/env bash
# Polls #synthetics-platform for PR review requests and runs adversarial review.
# @@CLAUDE@@ is substituted with the claude binary path at nix build time.

CLAUDE="@@CLAUDE@@"
STATE_DIR="$HOME/.local/state/slack-pr-reviewer"
FINDINGS_DIR="$HOME/.local/share/slack-pr-reviewer/findings"
STATE_FILE="$STATE_DIR/seen.json"
LOCK_FILE="$STATE_DIR/poll.lock"
LOG_FILE="$STATE_DIR/poll.log"

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >> "$LOG_FILE"
}

notify() {
  osascript -e "display notification \"$2\" with title \"$1\""
}

mkdir -p "$STATE_DIR" "$FINDINGS_DIR"

# Prevent concurrent runs via PID file
if [[ -f "$LOCK_FILE" ]]; then
  OLD_PID=$(cat "$LOCK_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    log "Already running (pid $OLD_PID), skipping"
    exit 0
  fi
fi
printf '%s' "$$" > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

[[ -f "$STATE_FILE" ]] || printf '[]' > "$STATE_FILE"
SEEN_JSON="$(cat "$STATE_FILE")"

log "Polling #synthetics-platform for PR review requests..."

# Step 1: Ask Claude to read Slack and return new PR URLs (uses Slack MCP tools)
SLACK_PROMPT="Use slack_search_channels to find the channel ID for 'synthetics-platform'. Then use slack_read_channel to get the last 200 messages. Find all GitHub PR URLs with the pattern https://github.com/*/pull/[number] — extract them from any format: bare URLs, markdown links like [text](url), or Slack's own <url|text> format. Include any PR a human posted; in this channel, sharing a PR link is itself a review request. Skip: bot messages, CI/automated posts, and any message that has one or more emoji reactions on it (reactions mean it has already been handled). These PRs have already been reviewed, exclude them: ${SEEN_JSON}. Output ONLY a newline-separated list of bare PR URLs (e.g. https://github.com/DataDog/foo/pull/123). No explanation, no markdown, just the URLs. If there are no new PRs, output nothing."

CLAUDE_OUTPUT=$("$CLAUDE" -p "$SLACK_PROMPT" 2>>"$LOG_FILE" || true)
log "DEBUG: Claude raw output: ${CLAUDE_OUTPUT}"

NEW_PRS=$(printf '%s' "$CLAUDE_OUTPUT" \
  | grep -E '^https://github\.com/[^[:space:]/]+/[^[:space:]/]+/pull/[0-9]+$' \
  || true)
log "DEBUG: URLs after grep filter: ${NEW_PRS:-<none>}"

if [[ -z "$NEW_PRS" ]]; then
  log "No new PRs found"
  exit 0
fi

log "New PRs to review: $(printf '%s' "$NEW_PRS" | tr '\n' ' ')"

while IFS= read -r PR_URL; do
  [[ -z "$PR_URL" ]] && continue

  PR_NUM=$(printf '%s' "$PR_URL" | grep -oE '[0-9]+$')
  REPO_PATH=$(printf '%s' "$PR_URL" | sed 's|https://github.com/||;s|/pull/[0-9]*$||')
  REPO_NAME=$(printf '%s' "$REPO_PATH" | cut -d/ -f2)

  log "Reviewing PR #${PR_NUM} from ${REPO_PATH}"

  # Mark as seen immediately so crashes don't cause re-review
  SEEN_JSON=$(printf '%s' "$SEEN_JSON" | python3 -c "
import json, sys
seen = json.load(sys.stdin)
url = '${PR_URL}'
if url not in seen:
    seen.append(url)
print(json.dumps(seen))
")
  printf '%s' "$SEEN_JSON" > "$STATE_FILE"

  # Skip already-merged or closed PRs
  PR_STATE=$(gh pr view "$PR_NUM" --repo "$REPO_PATH" --json state -q .state 2>/dev/null || printf 'UNKNOWN')
  if [[ "$PR_STATE" == "MERGED" || "$PR_STATE" == "CLOSED" ]]; then
    log "Skipping PR #${PR_NUM} — state is ${PR_STATE}"
    continue
  fi

  # Prefer an existing local clone with a git worktree (faster than cloning)
  WORK_DIR="/tmp/pr-review-${PR_NUM}-$$"
  USE_WORKTREE=false

  if [[ -d "$HOME/dd/${REPO_NAME}/.git" ]]; then
    LOCAL_REPO="$HOME/dd/${REPO_NAME}"
    if git -C "$LOCAL_REPO" fetch --quiet origin "pull/${PR_NUM}/head:pr/review/${PR_NUM}" 2>>"$LOG_FILE" \
       && git -C "$LOCAL_REPO" worktree add "$WORK_DIR" "pr/review/${PR_NUM}" 2>>"$LOG_FILE"; then
      USE_WORKTREE=true
    fi
  fi

  if [[ "$USE_WORKTREE" == "false" ]]; then
    if ! gh repo clone "$REPO_PATH" "$WORK_DIR" -- --depth=50 --quiet 2>>"$LOG_FILE"; then
      log "ERROR: clone failed for ${REPO_PATH}"
      notify "PR Review Error" "Failed to clone ${REPO_PATH}"
      continue
    fi
    if ! (cd "$WORK_DIR" && gh pr checkout "$PR_NUM" 2>>"$LOG_FILE"); then
      log "ERROR: checkout failed for PR #${PR_NUM}"
      rm -rf "$WORK_DIR"
      notify "PR Review Error" "Failed to checkout PR #${PR_NUM}"
      continue
    fi
  fi

  BASE=$(cd "$WORK_DIR" && gh pr view "$PR_NUM" --json baseRefName -q .baseRefName 2>/dev/null || printf 'main')
  log "Running adversarial review (base: ${BASE})"

  REVIEW=$(cd "$WORK_DIR" && "$CLAUDE" -p "/codex:adversarial-review --wait --base ${BASE}" 2>>"$LOG_FILE" || true)

  # Cleanup work dir
  if [[ "$USE_WORKTREE" == "true" ]]; then
    LOCAL_REPO="$HOME/dd/${REPO_NAME}"
    git -C "$LOCAL_REPO" worktree remove "$WORK_DIR" --force 2>/dev/null || true
    git -C "$LOCAL_REPO" branch -D "pr/review/${PR_NUM}" 2>/dev/null || true
  else
    rm -rf "$WORK_DIR"
  fi

  if [[ -z "$REVIEW" ]]; then
    log "ERROR: empty review output for PR #${PR_NUM}"
    notify "PR Review Error" "Review returned empty for PR #${PR_NUM}"
    continue
  fi

  if printf '%s' "$REVIEW" | grep -q '"needs-attention"'; then
    FINDINGS_FILE="${FINDINGS_DIR}/$(date +%s)-pr${PR_NUM}.txt"
    printf 'PR: %s\nReviewed: %s\n\n%s\n' \
      "$PR_URL" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$REVIEW" \
      > "$FINDINGS_FILE"
    log "Findings written to ${FINDINGS_FILE}"

    # Write the review script before showing the notification so it's ready to run
    REVIEW_SCRIPT=$(mktemp /tmp/pr-review-XXXXXX.sh)
    printf '#!/usr/bin/env bash\nexec %s '\''Read %s for the adversarial code review findings on PR %s. Summarize the key issues and ask me what I want to do about each one.'\''\n' \
      "$CLAUDE" "$FINDINGS_FILE" "$PR_URL" > "$REVIEW_SCRIPT"
    chmod +x "$REVIEW_SCRIPT"

    # Single notification with an Open action — clicking it opens Terminal with Claude
    osascript <<APPLESCRIPT
display notification "PR #${PR_NUM} needs attention — click to review" with title "PR Review: Action Needed" subtitle "${PR_URL}"
delay 0.5
tell application "Terminal"
  activate
  do script "$REVIEW_SCRIPT"
end tell
APPLESCRIPT
  else
    log "PR #${PR_NUM} approved — no critical issues"
    notify "PR Review: Looks Good" "No issues found — ${PR_URL}"
  fi

done <<< "$NEW_PRS"

log "Poll cycle complete"
