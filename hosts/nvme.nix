{ config, lib, pkgs, modulesPath, ... }:

{

  imports = 
    [
      ./common.nix
    ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/71ea0dc3-b267-43ba-902e-33edb9f906e5";
      preLVM = true;
      allowDiscards = true;
    };
  };

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

  networking.hostName = "nvme-ext";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
