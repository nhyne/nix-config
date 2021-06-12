{ config, lib, pkgs, modulesPath, ... }: {

  imports = 
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ 
    "xhci_pci" 
    "nvme" 
    "usb_storage" 
    "usbhid"
    "sd_mod" 
 #   "aes_x86_64"
    "aesni_intel" 
    "cryptd" 
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  #boot.initrd.luks.devices."luksroot".device = "/dev/disk/by-uuid/84138277-f825-4abc-b5c7-ed30dc3e00d9";

  boot.initrd.luks.devices = {
    luksroot = {
      name = "luksroot";
      device = "/dev/disk/by-uuid/84138277-f825-4abc-b5c7-ed30dc3e00d9";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    #{ device = "/dev/disk/by-uuid/527e016f-a9f8-4cf9-b969-f5331bdd5441";
    { device = "/dev/disk/by-uuid/666e016f-a9f8-4cf9-b969-f5331bdd5441";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3471-24AA";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/04ad8703-1c1b-4087-b355-a8a28aedaf72"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";



  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelParams = [ "intel_pstate=hwp" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #services.xserver.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.displayManager.gdm.enable = true;

  #networking.networkmanager.enable = true;
  #networking.hostName = "x1-nhyne";

  #powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  #hardware.video.hidpi.enable = lib.mkDefault true;

  nixpkgs.config.allowUnfree = true;
  #nix = {
  #  package = pkgs.nixFlakes;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  #  trustedUsers = [ "root" "nhyne" ];
  #};

#  environment.systemPackages = with pkgs; [
#    awscli2
#    bat
#    bitwarden
#    bitwarden-cli
#    brave
#    capnproto
#    dhall
#    discord
#    github-cli
#    gron
#    htop
#    jq
#    kubectl
#    loc
#    magic-wormhole
#    minikube
#    ncdu
#    ngrok
#    ocaml
#    postman
#    python # needed for bazel
#    ripgrep
#    rustup
#    saml2aws
#    sbt
#    scala
#    scalafix
#    scalafmt
#    shellcheck
#    siege
#    slack
#    spotify
#    sublime3
#    whois
#    xclip
#  ];
#
#  users.users.nhyne = {
#    isNormalUser = true;
#    extraGroups = [ "wheel" "networkmanager" ];
#    hashedPassword = "$6$D/lAnTaNHLizhkq/$PuEfWd/NutVUwBmLcxUNiK4MjLLmPFiPwBRE8JVSFzms.OUACwLGwqJusR2D3Y5CZGfVaV7XwEKtYHwy8wEOv/";
#    openssh.authorizedKeys.keys = [
#      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcgXoO+b3tsxHfrw4utcaQU9oXMu5JXTPVWfnTLItyaKBsrb1thIMHkK9mq/lG+oc/SDS32DJOjjezCPLrNULvunFS7wI4ipX2nmG308o/dn57R1+5/VUMj1kVRkYNOzsC57YN8FAkj7WUk6Tc1KVu8pWLa7EmhokcC7coPC+mtZgM9w3LPelIS3Eq+7Kp5ppoT6LPvaMr9OYsrk2PfOiaJHOO5+TgW5dt9jt89JVqVEZ8rY8QEOOzAhxUqV8OlwCgdXV2DbD+eY3A7azeNyaIur9VljDYqi9F1xE0ZwmU9ixJmE22JDJugVdCdaS0njb61mrU74IabQA8Yw/+0PNQF67AbObPpwdKTD88Fzg/0kY1YZXvOh6AmiF+pzuIJQDWNLxZnnIuEdP2Y0/Srme6IAooukDSY6S7aSbFLBGvR3GRBhbEEz9eVXVgy1RUejNAcUtHxlrAoK72nYqCLdDihexGDkMK6AHcOulqr/hvddu1VCEcRcxS4Lp4mjHxfs8= nhyne@nhyne-x16th
#"
#    ];
#  };
#
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
