# https://nixos.wiki/wiki/Home_Manager

# Stuff on this file, and ./*.nix, should work across all of my computing
# devices. Presently these are: Thinkpad, Macbook and Pixel Slate.

{ config, pkgs, device ? "unknown", ... }:

let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
    ./opam.nix
    ./haskell.nix
    ./go.nix
    ./nushell.nix
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
    #youtube-dl

    # kube related stuff
    kubectl
    minikube


    scala
    dhall
    python # needed for bazel
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

}
