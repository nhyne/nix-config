{ pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  baseImports = [ ./git.nix ./zsh.nix ./vim.nix ];
  goPath = "developer/go";

  ecrlogin = pkgs.writeShellScriptBin "ecrlogin"
    (pkgs.lib.fileContents ./scripts/ecr-login.sh);

  linuxPkgs = with pkgs;
    if !isDarwin then [
      bandwhich # network ps
      dhall
      difftastic
      dnsutils
      #dust # better du
      firefox
      gdb
      gnomeExtensions.caffeine
      grex # build regex cli
      inetutils
      magic-wormhole
      openjdk
      openssl
      # podman-compose
      rr # debugging tool
      sbt
      scala
      scalafix
      scalafmt
      siege
      terminator
      thunderbird
      vlc
      xclip
    ] else
      [ crane ];

  username = if isDarwin then "adam.johnson" else "nhyne";
  homeDir = if isDarwin then "/Users/adam.johnson" else "/home/nhyne";

in {
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  home.stateVersion = "23.11";

  imports = baseImports;

  home.sessionVariables = { EDITOR = "vim"; };
  home.username = username;
  home.homeDirectory = homeDir;

  programs.go = {
    enable = true;
    inherit goPath;
    goBin = "${goPath}/bin";
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    #    nix-direnv.enableFlakes = true;
  };

  services.gpg-agent.enable = !isDarwin;

  home.packages = with pkgs;
    [
      atuin
      awscli2
      bat
      bottom # better top
      buf
      # dig
      ecrlogin
#      exa # better ls
      fd # better find
      fzf
      github-cli
      git-machete
      gnupg
      gron # json grep
      jq
      just
      k9s
      kubectl
      kubectx
      loc
      lsof
      minikube
      nodejs
      ncdu
      nixfmt
#      obsidian
      procs # better ps
      ripgrep # faster grep
      rustup
      sd # sed
      shellcheck
      stern # multi pod logs in k8s
      inetutils
      rustup
      unison-ucm
      unzip
#      vector # tool to send things to DD easily
      zip
    ] ++ linuxPkgs;
}
