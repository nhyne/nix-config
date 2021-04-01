# https://nixos.wiki/wiki/Home_Manager

# Stuff on this file, and ./*.nix, should work across all of my computing
# devices. Presently these are: Thinkpad, Macbook and Pixel Slate.

# TODO: Pin pkgs with niv
{ config, pkgs, lib, ... }:


let
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
    ./opam.nix
    #./haskell.nix
    ./go.nix
  ];
  iheartImport = if (builtins.pathExists /Users/adamjohnson/iheart/amp/amp-nix-config) then [ /Users/adamjohnson/iheart/amp/amp-nix-config ./amp.nix ] else [] ;
  iheartpackages = with pkgs; if (builtins.pathExists /Users/adamjohnson/iheart/amp/amp-nix-config)
    then [] else [
        sbt
        awscli2
        kubectl
        scala
      ] ;
  linuxPackages = with pkgs; if (builtins.currentSystem != "x86_64-darwin")
    then
        [
            discord
            spotify
            postman
            brave
            sublime3
            bitwarden
            bitwarden-cli
        ]
     else [];


in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "ngrok"
    "postman"
    "discord"
    "slack"
    "spotify"
    "spotify-unwrapped"
    "sublimetext3"
    "authy"
  ];

  programs.home-manager.enable = true;

  imports = baseImports ++ iheartImport;

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
    siege
    loc
    ripgrep
    gron

    ngrok
    magic-wormhole
    capnproto

    #applications
    slack
    authy

    nodejs

    # kube related stuff
    minikube

    rustup

    scalafmt
    scalafix

    dhall
    python # needed for bazel
  ] ++ linuxPackages ++ iheartpackages;

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
