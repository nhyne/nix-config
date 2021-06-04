{ config, lib, pkgs, modulesPath, ... }: {

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ff7f290f-3905-41cd-bdba-5152b9d68391";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "D794-F18A";
    fsType = "vfat";
  };

boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

    nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "srid" ];
  };

  environment.systemPackages = with pkgs; [
    scala
  ];

  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

   # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
