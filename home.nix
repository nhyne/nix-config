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
  nixpkgs.config.allowUnfree = true;

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

    ngrok
    magic-wormhole

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

  services.caffeine.enable = true;

}
