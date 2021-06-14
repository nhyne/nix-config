{ config, lib, pkgs, modulesPath, ... }:

let
  argocd = pkgs.callPackage ./../argocd.nix {};
in
{

  imports = 
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.localtime.enable = true;
  services.geoclue2.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  time.timeZone = "America/New_York";

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/71ea0dc3-b267-43ba-902e-33edb9f906e5";
      preLVM = true;
      allowDiscards = true;
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7a1f578b-fdc9-40cc-8ff2-b143f111ffd5";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A3A7-CC8A";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1ba06006-4e9d-464c-b13b-8ec7c2ca397d"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.networkmanager.enable = true;
  networking.hostName = "x1-nhyne";

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

  environment.systemPackages = with pkgs; [
    argocd
    awscli
    bat
    brave
    dhall
    discord
    docker-compose
    github-cli
    gron
    helm
    htop
    jetbrains.idea-ultimate
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    ngrok
    openvpn
    postman
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
    spotify
    sublime3
    terminator
    whois
    xclip
    zoom-us
  ];

  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$mthz3HM4I3/Z9NI6$IuX3jnqicrIM5T9rXg/y/nTkrfijKoozxlqPYfN0mNdYw1F45X46pxaHW1rVJXioCyDfIGeI9InvMV2s5w21h1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcgXoO+b3tsxHfrw4utcaQU9oXMu5JXTPVWfnTLItyaKBsrb1thIMHkK9mq/lG+oc/SDS32DJOjjezCPLrNULvunFS7wI4ipX2nmG308o/dn57R1+5/VUMj1kVRkYNOzsC57YN8FAkj7WUk6Tc1KVu8pWLa7EmhokcC7coPC+mtZgM9w3LPelIS3Eq+7Kp5ppoT6LPvaMr9OYsrk2PfOiaJHOO5+TgW5dt9jt89JVqVEZ8rY8QEOOzAhxUqV8OlwCgdXV2DbD+eY3A7azeNyaIur9VljDYqi9F1xE0ZwmU9ixJmE22JDJugVdCdaS0njb61mrU74IabQA8Yw/+0PNQF67AbObPpwdKTD88Fzg/0kY1YZXvOh6AmiF+pzuIJQDWNLxZnnIuEdP2Y0/Srme6IAooukDSY6S7aSbFLBGvR3GRBhbEEz9eVXVgy1RUejNAcUtHxlrAoK72nYqCLdDihexGDkMK6AHcOulqr/hvddu1VCEcRcxS4Lp4mjHxfs8= nhyne@nhyne-x16th
"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
