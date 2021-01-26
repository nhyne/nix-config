# https://nixos.wiki/wiki/Home_Manager

# Stuff on this file, and ./*.nix, should work across all of my computing
# devices. Presently these are: Thinkpad, Macbook and Pixel Slate.

{ config, pkgs, ... }:


let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
    ./opam.nix
    ./haskell.nix
    ./go.nix
  ];
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "ngrok"
    "postman"
  ];

  programs.home-manager.enable = true;

  imports = baseImports;

  home.packages = with pkgs; [
    # To track sources
    niv

    # Basic tools
    htop
    #file
    jq
    bat
    shellcheck
    youtube-dl
    github-cli
    sbt
    siege
    loc
    ripgrep

    ngrok
    magic-wormhole
    #lastpass-cli
    brave
    postman
    capnproto

    nodejs
    awscli

    # kube related stuff
    kubectl
    minikube

    rustup

    scala
    scalafmt
    dhall
    python # needed for bazel
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

# need to limit to linux
#  services.caffeine.enable = true;

}
