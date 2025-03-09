{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  imports = [
    #     (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  sdImage.compressImage = false;

  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  nix = {
    #    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [
      "root"
      "nhyne"
    ];
  };

  # environment.systemPackages = with pkgs; [
  #   awscli2
  #   bat
  #   dhall
  #   htop
  #   jq
  #   kubectl
  #   loc
  #   magic-wormhole
  #   minikube
  #   ncdu
  #   ripgrep
  #   rustup
  #   saml2aws
  #   sbt
  #   shellcheck
  #   whois
  #   xclip
  # ];

    programs.zsh.enable = true;

  services = {
    openssh = {
      enable = true;
      #      permitRootLogin = "no";
      settings.PasswordAuthentication = false;
    };
  };

  users.mutableUsers = true;

  users.defaultUserShell = pkgs.zsh;
  users.groups = {
    nixos = {
      gid = 1000;
      name = "nixos";
    };
  };
  users.users = {
    nixos = {
      isSystemUser   = true;
      uid = 1000;
      home = "/home/nixos";
      name = "nixos";
      group = "nixos";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
    nhyne = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "password";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwxRycY1AvRNiEFOPtd3gerX/T68jHHkvDu1Y4I4vSxmgv9gZTgXMpli78KCwmZHiXoKE7uc1Nd5lVLCiHol4Zk5zNY2zJ7ltogu9KdzGxJK0axmSF5GnP74VNlWU93/0SzNpgH+PahbWyvMcFe4TVyKESVt2JQjXlhc3otutB+zoFXhVdbqVSm46N9NrxbsSyOhjfzjCc09cgc2o2P9fOe0JYwzpDDWQymnQVQ8fl/EzP0MWCje15YxHZjLgrvYE8K9qkUYSxTWYFDvEf8XzPr9Za5D5IDcfXaCgdDzlkn3x1qd5cDQqrhg1H8QqHnKL/imppdQRKyBxySuIDg6lj4SjTC/G/agxBcsCIzPIO/RSdlFWNyFvvIbGtZHYrduIlW8vSVa9qTNWZyIY8jZjRqi0R5Oe27OuRqp/0Egn9+j6ktjfc3cEYufNaPoAjxMK2OEt/bgHVQXEfPDHy33T094/rbIDS/F+q+k7jQCqW4AstRA/CVR3BOX4Isx70Q78= nhyne@nixos"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
