{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  linuxClipboard = {
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };
  shellAliases = {
    kubeami = "kubectl config current-context";
    ll = "exa -lah";
    wthr = "curl wttr.in";
    ghpr = "gh pr create";
    ecrlogin = "$(aws ecr get-login --no-include-email)";
    vi = "nvim";
    vim = "nvim";
    del = "trash";
    nixs = "nix search nixpkgs $@";
    nixm =
      "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz $@";
    summ = "paste -sd+ - | bc";
  } // (if isDarwin then { } else linuxClipboard);
  fzfConfig =
    pkgs.writeText "fzf-config" (lib.fileContents ./configs/fzf-config.zsh);

  ps1Config = pkgs.writeText "kube-ps1.sh" (pkgs.callPackage ./kube-ps1.nix {}).ps1;

  macSession = {
    PATH =
      "/etc/profiles/per-user/adam.johnson/bin:/run/current-system/sw/bin/:$PATH";
  };

in {

  programs.zsh = {
    enable = true;
    autocd = true;
    inherit shellAliases;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "kubectl" "aws" ];
    };
    sessionVariables = {
      EDITOR = "vim";
      SDKMAN_DIR = "$HOME/.sdkman";
      # PATH = "$HOME/.cargo/bin:$HOME/.jenv/bin:$GOBIN:$PATH";
      HISTTIMEFORMAT = "%d/%m/%y %T ";
      #SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=2G -Xmx2G $SBT_OPTS";
      KUBE_PS1_SYMBOL_ENABLE = false;
    } // (if isDarwin then macSession else { });
    history = {
      ignoreSpace = true;
      ignoreDups = true;
      extended = true;
      share = false;
      size = 100000;
      save = 100000;
    };
    initExtra = ''
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
      export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
      export NIX_PATH=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
      source ~/.dd-zshrc
      source ${fzfConfig}
      source ${ps1Config}
      export RPROMPT=$(kube_ps1)
      	'';
  };
}
