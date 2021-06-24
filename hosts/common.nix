{ lib, pkgs, modulesPath, ... }: 

let
  git-delete-squashed =
    pkgs.writeShellScriptBin "git-delete-squashed" ''
      # https://github.com/not-an-aardvark/git-delete-squashed
      set -e
      git checkout -q master
      git for-each-ref refs/heads/ "--format=%(refname:short)" | \
        while read branch
        do
          mergeBase=$(git merge-base master $branch)
          [[ $(git cherry master $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]]
          git branch -D $branch
        done
    '';
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
      };

      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
    # https://bugzilla.kernel.org/show_bug.cgi?id=110941
    kernelParams = [ "intel_pstate=no_hwp" ];
    extraModulePackages = [ ];
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false;
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp2s0.useDHCP = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.localtime.enable = true;
  services.geoclue2.enable = true;
  time.timeZone = "America/New_York";

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.networkmanager.enable = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "nhyne" ];
  };

  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$6wF2pVtSH$SxnyViR.tUPlLZSEJmuqccUlug/z99UebA41r8/VwxHh3NjDHtHPrqi.tY4jkExLio71aMibbIFJ1eg1.23M..";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwxRycY1AvRNiEFOPtd3gerX/T68jHHkvDu1Y4I4vSxmgv9gZTgXMpli78KCwmZHiXoKE7uc1Nd5lVLCiHol4Zk5zNY2zJ7ltogu9KdzGxJK0axmSF5GnP74VNlWU93/0SzNpgH+PahbWyvMcFe4TVyKESVt2JQjXlhc3otutB+zoFXhVdbqVSm46N9NrxbsSyOhjfzjCc09cgc2o2P9fOe0JYwzpDDWQymnQVQ8fl/EzP0MWCje15YxHZjLgrvYE8K9qkUYSxTWYFDvEf8XzPr9Za5D5IDcfXaCgdDzlkn3x1qd5cDQqrhg1H8QqHnKL/imppdQRKyBxySuIDg6lj4SjTC/G/agxBcsCIzPIO/RSdlFWNyFvvIbGtZHYrduIlW8vSVa9qTNWZyIY8jZjRqi0R5Oe27OuRqp/0Egn9+j6ktjfc3cEYufNaPoAjxMK2OEt/bgHVQXEfPDHy33T094/rbIDS/F+q+k7jQCqW4AstRA/CVR3BOX4Isx70Q78= nhyne@nixos
"
    ];
  };

  environment.systemPackages = with pkgs; [
    bandwhich # network ps
    bat
    bottom # better top
    brave
    dhall
    dust # better du
    exa # better ls
    fd # better find
    git-delete-squashed
    github-cli
    gnomeExtensions.caffeine
    grex # build regex cli
    gron # json grep
    jetbrains.idea-ultimate
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    ngrok
    ocaml
    postman
    procs # better ps
    ripgrep # faster grep
    rustup
    sbt
    scala
    scalafix
    scalafmt
    sd # sed
    shellcheck
    siege
    slack
    spotify
    sublime4
    terminator
    whois
    xclip
    zoom-us
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}