{ config, lib, ... }:

let
  shellAliases = {
    kubeami = "kubectl config current-context";
    ll = "exa -lah";
    wthr = "curl wttr.in";
    ghpr = "gh pr create";
    #  ecrlogin = "$(aws ecr get-login --no-include-email)";
    vi = "nvim";
    vim = "nvim";
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
    del = "trash";
    nixs = "nix search nixpkgs $@";
    nixm = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz $@";
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
      plugins = [ "kubectl" "aws" "ruby" ];
    };
    sessionVariables = {
      EDITOR = "vim";
      SDKMAN_DIR = "$HOME/.sdkman";
      PATH = "/etc/profiles/per-user/adam.johnson/bin:/run/current-system/sw/bin/:$PATH";
      # PATH = "$HOME/.cargo/bin:$HOME/.jenv/bin:$GOBIN:$PATH";
      HISTTIMEFORMAT = "%d/%m/%y %T ";
      #SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=2G -Xmx2G $SBT_OPTS";
    };
    history = {
      ignoreSpace = true;
      ignoreDups = true;
      extended = true;
      share = false;
      size = 100000;
      save = 100000;
    };
    profileExtra = ''
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
      export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
      export NIX_PATH=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
      	'';
    initExtraBeforeCompInit = ''
        '';
      # . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"  
      # source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
  };
}
