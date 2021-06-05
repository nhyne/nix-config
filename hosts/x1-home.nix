{ config, lib, pkgs, modulesPath, ... }: {

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  #fileSystems."/boot/efi" = {
  #  device = "D794-F18A";
  #  fsType = "vfat";
  #};

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    bitwarden
    bitwarden-cli
    brave
    capnproto
    dhall
    discord
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
    ocaml
    postman
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
    spotify
    sublime3
    whois
    xclip
  ];

  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$/0/o0DxSxfB5$gePPeYCZwSjNDeBkX47PHYj/JYjfqD7Q.nQ1TTYnHzz4tjmD8BUDcLRErcuj2w6M/q.OqxouFr5cLmIGPKb1d/";
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
  system.stateVersion = "20.09"; # Did you read the comment?

}
