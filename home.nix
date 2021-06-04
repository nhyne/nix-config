{ ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (_: _: { inherit sources; })
    ];
  };

  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
  ];
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

  goPath = "developer/go";

in {
  programs.home-manager.enable = true;

  imports = baseImports;

  home.packages = with pkgs; [
    awscli
#   awscli2
    bat
#   cabal-install
    capnproto
    dhall
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
#   stack
    whois
    xclip
    youtube-dl
  ] ++ linuxPackages;

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
