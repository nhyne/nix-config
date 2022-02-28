{ pkgs, ... }:

let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
  ];
  goPath = "developer/go";
  ecrlogin = pkgs.writeShellScriptBin "ecrlogin" (pkgs.lib.fileContents ./scripts/ecr-login.sh);

in {
  programs.home-manager.enable = true;

  imports = baseImports;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.go = {
    enable = true;
    inherit goPath;
    goBin = "${goPath}/bin";
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.gpg-agent.enable = true;

  home.packages = with pkgs; [
    awscli2
    bandwhich # network ps
    bat
    bottom # better top
    # dhall
    dig
    dust # better du
    ecrlogin
    exa # better ls
    fd # better find
    firefox
    github-cli
    gnomeExtensions.caffeine
    gnupg
    grex # build regex cli
    gron # json grep
    insomnia
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    # ocaml
    openjdk
    procs # better ps
    ripgrep # faster grep
    sbt
    scala
    scalafix
    scalafmt
    sd # sed
    shellcheck
    siege
    stern # multi pod logs in k8s
    terminator
    unzip
    vlc
    whois
    xclip
    zip
  ];
# need to limit to linux
#  services.caffeine.enable = true;
}
