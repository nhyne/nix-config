{ config, lib, pkgs, modulesPath, ... }: {

  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
#  boot.loader.grub.forceInstall = true;
#  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;
#
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c03a8673-2773-4deb-b4dd-8717ca258bac";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6c7df943-47b6-4b30-a698-681739d32b2d"; }
    ];
#  swapDevices = [ { device = "/dev/sdb"; } ];

  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "nhyne" ];
  };

  environment.systemPackages = with pkgs; [
    awscli2
    bat
    dhall
    htop
    jq
    kubectl
    loc
    magic-wormhole
    minikube
    ncdu
    ripgrep
    rustup
    saml2aws
    sbt
    shellcheck
    whois
    xclip
  ];

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = true;
    };
  };

  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$/0/o0DxSxfB5$gePPeYCZwSjNDeBkX47PHYj/JYjfqD7Q.nQ1TTYnHzz4tjmD8BUDcLRErcuj2w6M/q.OqxouFr5cLmIGPKb1d/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwxRycY1AvRNiEFOPtd3gerX/T68jHHkvDu1Y4I4vSxmgv9gZTgXMpli78KCwmZHiXoKE7uc1Nd5lVLCiHol4Zk5zNY2zJ7ltogu9KdzGxJK0axmSF5GnP74VNlWU93/0SzNpgH+PahbWyvMcFe4TVyKESVt2JQjXlhc3otutB+zoFXhVdbqVSm46N9NrxbsSyOhjfzjCc09cgc2o2P9fOe0JYwzpDDWQymnQVQ8fl/EzP0MWCje15YxHZjLgrvYE8K9qkUYSxTWYFDvEf8XzPr9Za5D5IDcfXaCgdDzlkn3x1qd5cDQqrhg1H8QqHnKL/imppdQRKyBxySuIDg6lj4SjTC/G/agxBcsCIzPIO/RSdlFWNyFvvIbGtZHYrduIlW8vSVa9qTNWZyIY8jZjRqi0R5Oe27OuRqp/0Egn9+j6ktjfc3cEYufNaPoAjxMK2OEt/bgHVQXEfPDHy33T094/rbIDS/F+q+k7jQCqW4AstRA/CVR3BOX4Isx70Q78= nhyne@nixos
"
    ];
  };

   # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
