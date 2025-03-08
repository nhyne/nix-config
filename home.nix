{ pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  baseImports = [
    ./git.nix
    ./zsh.nix
    ./vim.nix
  ];
  goPath = "developer/go";

  ecrlogin = pkgs.writeShellScriptBin "ecrlogin" (pkgs.lib.fileContents ./scripts/ecr-login.sh);

  linuxPkgs =
    with pkgs;
    if !isDarwin then
      [
        bandwhich # network ps
        dhall
        difftastic
        dnsutils
        #dust # better du
        firefox
        gcc
        gdb
        gnomeExtensions.caffeine
        grex # build regex cli
        inetutils
        magic-wormhole
        mitmproxy
        openjdk
        openssl
        # podman-compose
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
       substituters = [
           "https://nix-community.cachix.org"
       ];
       trusted-public-keys = [
         "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  home.packages =
    with pkgs;
    [
      atuin
      awscli2
      bat
      bottom # better top
      buf
      cachix
      # dig
      difftastic
      ecrlogin
      #      exa # better ls
      fd # better find
      fzf
      github-cli
      git-machete
      gnupg
      gron # json grep
      jq
      just
      k9s
      kubectl
      kubectx
      tokei
      lsof
      minikube
      nodejs
      ncdu
      nixfmt-rfc-style
      #      obsidian
      procs # better ps
      ripgrep # faster grep
      sd # sed
      shellcheck
      stern # multi pod logs in k8s
      treefmt
      inetutils
      #unison-ucm
      unzip
      #      vector # tool to send things to DD easily
      zip
    ]
    ++ linuxPkgs;
}
