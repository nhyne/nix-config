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
    bat
    bottom # better top
    diskus # better du
    dnsutils
    fd # better find
    fzf
    git
    gnupg
    gron # json grep
    hexyl # hex data viewing
    hyperfine # cli benchmark
    inetutils # for net stuff like telnet
    jq
    lsof
    openssl
    pastel # color manipulation
    ripgrep # faster grep
    sd # sed
    tokei # code statistics
    treefmt # formatter for many file types
    unzip
    zip
  ];

  defaultPkgs = with pkgs; [
    atuin # command history tool
    awscli2
    buf # protocol buffer tool
    cachix # nix cache
    cacert
    delta
    dig
    difftastic # better diff
    duf # better df
    ecrlogin
    erlang
    eza # better ls
    github-cli
    git-machete
    gleam # functional programming language
    glow # markdown viewer
    just # task runner
    k9s
    kubectl
    kubectx
    miller # cli data manipulation
    minikube
    nodejs
    nixfmt-rfc-style
    shellcheck
    stern # multi pod logs in k8s
    unison-ucm # unison programming language
    vector # tool to send things to DD easily
    viddy # modern watch
  ];

  linuxPkgs =
    with pkgs;
    if !isDarwin then
      [
        dhall
        difftastic
        dust # better du
        firecracker
        firectl
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
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    # setting the nix_ssl_cert_file is necessary to fix x509 cert issues with proxy.golang.org
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
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
    enable = !isServer;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      sync_address = "nowhere";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$battery $directory$git_branch$git_status$git_state$direnv$custom$sudo$character";
      right_format = "$kubernetes";
      command_timeout = 3000;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      git_branch = {
        format = "([git:\\(](blue)[$branch](red)[\\)](blue))";
      };
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style))";
        style = "yellow";
        modified = "m";
        stashed = "s";
        deleted = "x";
      };
      git_state = {
        format = "\([$state( $progress_current/$progress_total)]($style)\)";
      };
      cmd_duration = {
        min_time = 3000;
      };
      direnv = {
        disabled = false;
        format = "[$loaded]($style)";
        loaded_msg = ":";
        unloaded_msg = "";
        allowed_msg = "";
        not_allowed_msg = "";
        denied_msg = "";
        style = "bold purple";
      };
      line_break = {
        disabled = true;
      };
      kubernetes = {
        disabled = false;
        format = "(\\([$context](red bold):[$namespace](cyan bold)\\))";
      };
    };
  };

  services.gpg-agent.enable = !isDarwin;

  home.packages = with pkgs; if isServer then serverPkgs else serverPkgs ++ defaultPkgs ++ linuxPkgs;
}
