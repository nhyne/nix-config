# After rebuilding, ensure ~/.claude/settings.json has these Slack MCP tools
# in permissions.allow (the launchd agent can't handle interactive prompts):
#
#   "mcp__plugin_slack_slack__slack_search_channels",
#   "mcp__plugin_slack_slack__slack_read_channel",
#   "mcp__plugin_slack_slack__slack_read_thread",
#   "mcp__plugin_slack_slack__slack_search_public",
#   "mcp__plugin_slack_slack__slack_search_public_and_private"
#
# settings.json is not nix-managed so it won't survive a rebuild automatically.

{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  claudeBin = "/Users/adam.johnson/.local/bin/claude";

  slackPrPoll = pkgs.writeShellApplication {
    name = "slack-pr-poll";
    runtimeInputs = with pkgs; [ git github-cli python3 ];
    # osascript heredocs and dynamic string construction don't play well with shellcheck
    checkPhase = "";
    text = builtins.replaceStrings
      [ "@@CLAUDE@@" ]
      [ claudeBin ]
      (builtins.readFile ./scripts/slack-pr-poll.sh);
  };

in
lib.mkIf isDarwin {
  home.packages = [ slackPrPoll ];

  launchd.agents.slack-pr-reviewer = {
    enable = true;
    config = {
      ProgramArguments = [ "${slackPrPoll}/bin/slack-pr-poll" ];
      StartInterval = 900;
      RunAtLoad = true;
      StandardOutPath = "/tmp/slack-pr-reviewer-stdout.log";
      StandardErrorPath = "/tmp/slack-pr-reviewer-stderr.log";
      EnvironmentVariables = {
        HOME = "/Users/adam.johnson";
        PATH = lib.concatStringsSep ":" [
          "/Users/adam.johnson/.local/bin"
          "/etc/profiles/per-user/adam.johnson/bin"
          "/opt/homebrew/bin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
        ];
      };
    };
  };
}
