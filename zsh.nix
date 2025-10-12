{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  linuxClipboard = {
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };
  shellAliases = {
    kubeami = "kubectl config current-context";
    ll = "eza -lah";
    ghpr = "gh pr create";
    vi = "nvim";
    vim = "nvim";
    del = "trash";
    nixs = "nix search nixpkgs $@";
    nixm = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz $@";
    summ = "paste -sd+ - | bc";
    history = "history -f";
    loc = "tokei";
    watch = "viddy";
    cd = "z";
    diff = "difft";
    claude = "npx @anthropic-ai/claude-code";
  } // (if isDarwin then { } else linuxClipboard);
  fzfConfig = pkgs.writeText "fzf-config" (lib.fileContents ./configs/fzf-config.zsh);

  macSession = {
    PATH = "/etc/profiles/per-user/adam.johnson/bin:/run/current-system/sw/bin/:$PATH";
  };

in
{
  programs.zoxide.enable = true; # smarter cd

  programs.zsh = {
    enable = true;
    autocd = true;
    inherit shellAliases;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "kubectl"
        "aws"
        "kube-ps1"
      ];
    };
    sessionVariables = {
      EDITOR = "vim";
      SDKMAN_DIR = "$HOME/.sdkman";
      # PATH = "$HOME/.cargo/bin:$HOME/.jenv/bin:$GOBIN:$PATH";
      HISTTIMEFORMAT = "%d/%m/%y %T ";
      #SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=2G -Xmx2G $SBT_OPTS";
      KUBE_PS1_SYMBOL_ENABLE = false;
      #RPROMPT="$(kube_ps1)";
    } // (if isDarwin then macSession else { });
    history = {
      ignoreSpace = true;
      ignoreDups = true;
      extended = true;
      share = false;
      size = 1000000;
      save = 1000000;
    };
    initExtra = pkgs.lib.strings.trim (
      ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
        export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
        export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels:$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
        setopt inc_append_history
        setopt share_history
        source ${fzfConfig}
        eval "$(zoxide init bash)"
        
        wthr() {
          if [ $# -eq 0 ]; then
            curl wttr.in
          else
            curl "wttr.in/$1"
          fi
        }
      ''
      + (if isDarwin then "source ~/.dd-zshrc" else "")
    );
  };
}
