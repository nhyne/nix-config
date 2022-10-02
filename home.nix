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
      #dust # better du
      firefox
      gdb
      gnomeExtensions.caffeine
      grex # build regex cli
      magic-wormhole
      ocaml
      openjdk
      openssl
      podman-compose
      rr # debugging tool
      sbt
      scala
      scalafix
      scalafmt
      siege
      telnet
      terminator
      vlc
      whois
      xclip
    ] else
      [ ];

in {
  programs.home-manager.enable = true;
  home.stateVersion = "22.05";

  imports = baseImports;

  home.sessionVariables = { EDITOR = "vim"; };
  home.username = "adam.johnson";
  home.homeDirectory = "/Users/adam.johnson";

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

  # services.gpg-agent.enable = true;

  home.packages = with pkgs; [
    awscli2
    bat
    bottom # better top
    buf
    # dig
    ecrlogin
    exa # better ls
    fd # better find
    github-cli
    gnupg
    gron # json grep
    jq
    kubectl
    loc
    lsof
    minikube
    ncdu
    nixfmt
    procs # better ps
    ripgrep # faster grep
    sd # sed
    shellcheck
    stern # multi pod logs in k8s
    inetutils
    unzip
    zip
  ];
}
