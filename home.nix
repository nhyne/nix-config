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

  home.packages = with pkgs; [
    awscli
#   awscli2
    bat
    bitwarden
    bitwarden-cli
    brave
#   cabal-install
    capnproto
    dhall
    discord
#   ghc
    github-cli
    gron
    htop
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    ngrok
    niv
    nodejs
    ocaml
    postman
    python # needed for bazel
    ripgrep
    rustup
    saml2aws
    sbt
    scala
    scalafix
    scalafmt
    shellcheck
    siege
    slack
    spotify
#   stack
    sublime3
    whois
    xclip
    youtube-dl
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.go = {
    enable = true;
    inherit goPath;
    goBin = "${goPath}/bin";
  };
  programs.opam = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };
# need to limit to linux
#  services.caffeine.enable = true;
}
