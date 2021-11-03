{ pkgs, ... }:

let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
  ];
  goPath = "developer/go";

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
    dhall
    dig
    dust # better du
    exa # better ls
    fd # better find
    firefox
    github-cli
    gnomeExtensions.caffeine
    gnupg
    grex # build regex cli
    gron # json grep
    idris2
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    ocaml
    openjdk16
    procs # better ps
    ripgrep # faster grep
    rustup
    sbt
    scala
    scalafix
    scalafmt
    sd # sed
    shellcheck
    siege
    terminator
    trash-cli
    unison-ucm
    unzip
    whois
    xclip
    zip
  ];
# need to limit to linux
#  services.caffeine.enable = true;
}
