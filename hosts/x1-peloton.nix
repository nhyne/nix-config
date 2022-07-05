{ config, lib, pkgs, modulesPath, ... }:

let 
  argocd = pkgs.callPackage ./../argocd.nix { };
  saml2aws = pkgs.callPackage ./../saml2aws.nix { };
in {

  imports = [ ./common.nix ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/77f430d0-d9b5-4f81-9731-6eecb739c6ff";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/65de627d-425b-43b9-8ee8-8def123d79fc";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7601-C5D1";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/e31cfbf9-ba2c-4b98-89d6-08394230ed71"; }];

  networking = {
    hostName = "x1-peloton";
    useDHCP = false;
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
  };

  services.globalprotect.enable = true;

  services.hound = {
    enable = true;
    config = (pkgs.lib.fileContents ./../configs/peloton-hound.json);
  };

  environment.systemPackages = with pkgs; [
    argocd
    awscli
    docker-compose
    globalprotect-openconnect
    kubernetes-helm
    kustomize
    openvpn
    operator-sdk
    saml2aws
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
