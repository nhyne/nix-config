# https://nixos.wiki/wiki/Home_Manager

# Stuff on this file, and ./*.nix, should work across all of my computing
# devices. Presently these are: Thinkpad, Macbook and Pixel Slate.

{ config, pkgs, device ? "unknown", ...}:

let
  imports = [
    ./git.nix
    ./haskell.nix
    ./shells.nix
    ./tmux.nix
    ./emacs
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # To track sources
    niv

    # Basic tools
    htop
    #file
    jq
    #youtube-dl

    kubectl
    minikube
    scala

    # Dev tools
    #gnumake
    #ripgrep
    #tig
    #tmate
    #gitAndTools.gh
    dhall
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

}
