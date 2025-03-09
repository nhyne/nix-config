{ pkgs, ... }@args:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  isServer = args.isServer or false;
  baseImports = [
    ./git.nix
    ./zsh.nix
  ] ++ (if isServer then [ ] else [ ./vim.nix ]);
  goPath = "developer/go";

  ecrlogin = pkgs.writeShellScriptBin "ecrlogin" (pkgs.lib.fileContents ./scripts/ecr-login.sh);

  serverPkgs = with pkgs; [
    dnsutils
    inetutils
    openssl
    atuin
    bat
    bottom # better top
    fd # better find
    fzf
    git
    gnupg
    gron # json grep
    jq
    tokei
    lsof
    ripgrep # faster grep
    sd # sed
    treefmt
    inetutils
    unzip
    zip
  ];

  defaultPkgs = with pkgs; [
    awscli2
    buf
    cachix
    dig
    difftastic
    ecrlogin
    github-cli
    git-machete
    just
    k9s
    kubectl
    kubectx
    minikube
    nodejs
    ncdu
    nixfmt-rfc-style
    procs # better ps
    shellcheck
    stern # multi pod logs in k8s
    unison-ucm
    vector # tool to send things to DD easily
  ];

  linuxPkgs =
    with pkgs;
    if !isDarwin then
      [
        dhall
        difftastic
        dust # better du
        firefox
        gcc
        gdb
        gnomeExtensions.caffeine
        grex # build regex cli
        magic-wormhole
        mitmproxy
        openjdk
        podman-compose
        rr # debugging tool
        rustup
        sbt
        scala
        scalafix
        scalafmt
        siege
        terminator
        thunderbird
        vlc
        xclip
      ]
    else
      [ crane ];

  username = if isDarwin then "adam.johnson" else "nhyne";
  homeDir = if isDarwin then "/Users/adam.johnson" else "/home/nhyne";

in
{
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  home.stateVersion = "24.11";

  imports = baseImports;

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.lib.mkForce pkgs.nix;
    settings = {
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nhyne.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nhyne.cachix.org-1:wmICkGYz3W2Y4iEFNpXWtZmlRhqSJzvvslYnZhifg+g="
      ];
    };

  };

  home.sessionVariables = {
    EDITOR = "vim";
  };
  home.username = username;
  home.homeDirectory = homeDir;

  programs.go = {
    enable = true;
    inherit goPath;
    package = pkgs.go_1_23;
    goBin = "${goPath}/bin";
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    #    nix-direnv.enableFlakes = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      sync_address = "nowhere";
    };
  };

  services.gpg-agent.enable = !isDarwin;

  home.packages = with pkgs; if isServer then serverPkgs else serverPkgs ++ defaultPkgs ++ linuxPkgs;
}
