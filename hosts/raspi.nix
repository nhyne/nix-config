{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  nix-config = pkgs.fetchFromGitHub {
    owner = "nhyne";
    repo = "nix-config";
    rev = "90efe0715f8541102c832438339cae73e7a76975";
    hash = "sha256-JimllhqQZ18oauBQ3mOOzsr0k9hZqwa3UHd3dpK/M1Q=";
  };
  wifiPassword = builtins.getEnv "LABHOUSE_WIFI_PSK";
in
{

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  environment.variables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    # setting the nix_ssl_cert_file is necessary to fix x509 cert issues with proxy.golang.org
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  sdImage.compressImage = false;

  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  system.activationScripts.fetchRepo.text = ''
    mkdir -p /home/nhyne/developer/nix-config
    cp -r ${nix-config}/* /home/nhyne/developer/nix-config
    chown -R nhyne:nhyne /home/nhyne/developer/nix-config
  '';

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [
      "root"
      "nhyne"
    ];
  };

  programs.zsh.enable = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    tailscale = {
      enable = true;
    };
  };

  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "127.0.0.1:53:53/tcp"
        "127.0.0.1:53:53/udp"
        "3080:80"
        "30443:443"
      ];
      volumes = [
        "/var/lib/pihole/:/etc/pihole/"
        "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
      ];
      environment = {
        ServerIP = "127.0.0.1";
      };
      workdir = "/var/lib/pihole/";
    };

    datadog-agent = {
      image = "gcr.io/datadoghq/agent:7";

      volumes = [
        "/proc/:/host/proc/:ro"
        "/sys/fs/cgroup/:/host/sys/fs/cgroup:ro"
      ];

      environment = {
        DD_SITE = "datadoghq.com";
        DD_API_KEY = builtins.getEnv "DATADOG_API_KEY";
        DD_LOGS_ENABLED = "true";
        DD_CHECK_RUNNERS = "2";
        DD_PROCESS_CONFIG_PROCESS_COLLECTION_ENABLED = "true";
        DD_PROCESS_AGENT_ENABLED = "true";
        DD_TAGS = "env:labhouse host:raspi";
      };

      ports = [ "8125:8125/udp" ]; # StatsD port
      extraOptions = [
        "--cgroupns=host"
        "--pid=host"
        "--name=dd-agent"
      ];
    };

  };

  #docker run -d --cgroupns host --pid host --name dd-agent -e DD_SITE=<DATADOG_SITE> -e DD_API_KEY=<DATADOG_API_KEY> gcr.io/datadoghq/agent:7

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  networking = {
    #    networkmanager.enable = true;
    wireless.enable = true;
    wireless.interfaces = [ "wlan0" ];
    wireless.userControlled.enable = true;
    wireless.networks.LabHouse.psk = wifiPassword;
  };

  users = {

    mutableUsers = true;
    defaultUserShell = pkgs.zsh;
    groups = {
      nixos = {
        gid = 1000;
        name = "nixos";
      };
    };
    users = {
      nixos = {
        isSystemUser = true;
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
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        password = "password";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChnSW0axneEtRbCLcJhmfwrXWnJH+hXWlQQbF02q9/IwRYlgr+3llL1+55aDbhEnlisPVZIrfGKOO3rR63dQLtuBX4mT/mh3Tj7oQqZbOnQCNRl4wVKvesVUmKr1+S6ac+gVQ1QBSi+4q/wYn9POoLDl0nHXbcSDMkVSkiGmaVj7nuXZ60fX9iaXmI8STRl53Y3N1ij1YqWmUFLeE7ASv+++EMAgvEPT19cujF3BjUpoA9G/UjpjC479ye4lJnHWcrWzl8CusaA6ddxhjVo/Q3zw2bAOobyKBX91Pq/lWTGgt2/ztYzb8yrTpTLjCfh8EKcflkrV/sHVba/6hH5v1xH9GjaRzUMIHuZXJnrlcbYnWxht5RWIIBiqaHMfAaRdptyTvRDQ9SsVbadJnxv1QIuMwmuQgSD2lRYkgl6UowuJ8c/ft9K9EAkCinytKVZPi0I4K44XZgD80+2sWieFzGSo9h7veFxmSNFKlEhua0D+HLo8O3h0SqnJJPvbV0xuU= nhyne@DESKTOP-OMORADC"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMke6tOxMa78tRaK1vyQw8cTL4yUZ35rDSo4bD+Q4VYO nhyne@nhyne.dev"
        ];
      };
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
