{ config, lib, pkgs, ... }:

{
  programs.git = {
    #package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "nhyne";
    userEmail = "nhyne@nhyne.dev";
    aliases = {
      c = "checkout";
      cm = "commit";
      cmn = "commit --no-verify";
      a = "add";
      f = "fetch";
      ae = "add -u"; #adds all modified, does not add new files
      all = "add ."; #adds all modified files
      s = "status -sb"; #short status
      u = "reset HEAD --"; #unstages a file or directory from a commit after it has been added
      unch = "update-index --assume-unchanged"; #mark file unchanged locally
      amd = "commit --amend"; #allows you to edit commit message for previous commit
      undo = "checkout --"; #undo changes to a file
      undoall = "reset --hard HEAD"; #undoes changes to all files
      clearall = "!f() { git clean -fd; git reset --hard; }; f"; #undoes all changes and removes all added files, resets to most recent commit
      patch = "add --patch"; #adds modifications to files in groups
      dw = "diff --word-diff --ignore-space-change"; #in-line git diff
      b = "branch";
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
      rb = "!f() { git rebase -i HEAD^$1; }; f"; #interactive git rebase for the previous X commits
      sq = "!f() { git reset --soft HEAD^$1 && git commit; }; f"; #should automatically squash the last N commits into a single one with new commit message
      sl = "stash list"; #lists stashes
      sp = "stash pop"; #pops top stash and applies
      l = "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit"; #nice git log with graph
      lf = "!f() { git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit --follow $1; }; f";
      lfc = "!f() { git diff-tree --no-commit-id --name-only -r $1; }; f";
      dc = "!f() { git diff-tree --no-commit-id --name-only -r $1; }; f"; #shows files modified in given commit
      dwc = "!f() { git diff --word-diff --no-commit-id --ignore-space-change -r $1^ $1; }; f"; # shows the line by line changes made by a single commit
      blm = "blame -c -w --date=short";
      fls = "!f() { git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit --all --full-history -- $1; }; f"; #searches code base for a file as a given path, can include deleted files
      pr = "!f() { git dw $1...HEAD; }; f"; #makes PR-like diff on local
      cp = "cherry-pick";
      bd = "!f() { delete-squashed $1; }; f";
      show-merge = "!sh -c 'merge=$(git find-merge $0 $1) && [ -n \"$merge\" ] && git show $merge'";
      # Have an issue with these aliases because they include '@'
      ss = "stash save";
      ssf = "stash push";
      ssa = "stash save -u";
      #ss = "!f() { git stash save ${@:1}; }; f"; #stashes changes with a saved message, message does not have to be put into quotes
      #find-merge = "!sh -c 'commit=$0 && branch=${1:-HEAD} && (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 -s | uniq -f1 -d | sort -n | tail -1 | cut -f2'";
      #ssa = "!f() { git stash save -u ${@:1}; }; f"; #stashes everything with a message, message does not have to be put into quotes
    };
    ignores = [
      ".idea"
      ".DS_Store"
      "result"
      "target"
      ".terraform"
      ".ijwb"
      "bazel-*"
      "stale_outputs_checked"
      ".bloop"
      ".metals"
      "*.iml"
      "nogit"
    ];
    extraConfig = {
      core.editor = "nvim";
      #credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";
      branch.autosetuprebase = "always";
      branch.autosetupmerge = "always";
      merge.conflictstyle = "diff3";
      push.default = "current";
      init.defaultBranch = "main";
      diff."ansible-vault".textconv = "ansible-vault view";
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
        "git://" = {
          insteadOf = "https://";
        };
      };
    };
  };
}
