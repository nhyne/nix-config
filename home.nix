# TODO: Pin pkgs with niv
{ config, lib, sources ? import ./sources.nix, ... }:
#{ sources ? import ./sources.nix }:

let
  sources = import ./nix/sources.nix;
  mypkgs = import sources.nixpkgs { };
  home-manager = (import sources.home-manager { }).home-manager;

  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
    ./opam.nix
    #./haskell.nix
    ./go.nix
  ];
  iheartImport = if (builtins.pathExists /Users/adamjohnson/iheart/amp/amp-nix-config) then [ /Users/adamjohnson/iheart/amp/amp-nix-config ./amp.nix ] else [] ;
  iheartpackages = with mypkgs; if (builtins.pathExists /Users/adamjohnson/iheart/amp/amp-nix-config)
    then [] else [
        sbt
        awscli2
        kubectl
        scala
      ] ;
  linuxPackages = with mypkgs; if (builtins.currentSystem != "x86_64-darwin")
    then
        [
            discord
            spotify
            postman
            brave
            sublime3
            bitwarden
            bitwarden-cli
            authy
        ]
     else [];


in
{
  nixpkgs.config.allowUnfreePredicate = pkgg: builtins.elem (mypkgs.lib.getName pkgg) [
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

  home.packages = with mypkgs; [
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
    whois
    ncdu

    ngrok
    magic-wormhole
    capnproto

#    #applications
    slack

    nodejs

#    # kube related stuff
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
