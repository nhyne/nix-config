{ config, lib, pkgs, modulesPath, ... }: {

  imports = 
    [
      ./common.nix
    ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/6860b9d1-5498-4e2e-96b7-7e74e456b397";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7b5dda5b-d5be-4075-9eb6-1fc27c6bc224";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5A98-A29D";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/82db1de2-0d51-4308-a224-7e341b6fcbeb"; }
    ];

  networking.hostName = "x1-nhyne";

  environment.systemPackages = with pkgs; [
    bazel
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
