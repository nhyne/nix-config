---
description: Checkout and adversarially review a GitHub PR
argument-hint: <PR URL>
allowed-tools: Bash, Read, Glob, Grep
---

Review the pull request: $ARGUMENTS

Steps:

1. Parse the PR URL to extract OWNER/REPO and PR number.

2. Clone the repo into a temp worktree and checkout the PR:
   ```bash
   PR_NUM=<number>
   REPO=<OWNER/REPO>
   WORK_DIR="/tmp/review-pr-${PR_NUM}"
   gh repo clone "$REPO" "$WORK_DIR" -- --depth=50 --quiet
   cd "$WORK_DIR"
   gh pr checkout "$PR_NUM"
   BASE=$(gh pr view "$PR_NUM" --json baseRefName -q .baseRefName)
   ```

3. Run the adversarial review from that directory:
   `/codex:adversarial-review --wait --base $BASE`

4. Present results:
   - **Findings found** (`needs-attention`): Show each finding with file, line numbers, impact, and recommended fix. Then ask the user what they want to do about each one (fix it, accept the risk, or investigate further).
   - **Clean** (`approve`): Say "Looks good! No critical issues found." and show the PR link.

5. Cleanup: `rm -rf "$WORK_DIR"`
