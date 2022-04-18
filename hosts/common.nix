{ lib, pkgs, modulesPath, ... }: 

let
  delete-squashed = pkgs.writeShellScriptBin "delete-squashed" (lib.fileContents ./../delete-squashed.sh);
  zoom = pkgs.zoom-us.overrideAttrs (old: {
    postFixup = old.postFixup + ''
      wrapProgram $out/bin/zoom-us --unset XDG_SESSION_TYPE
    '';});
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
      };

      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
    # https://bugzilla.kernel.org/show_bug.cgi?id=110941
    kernelParams = [ "intel_pstate=no_hwp" ];
    extraModulePackages = [ ];
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #   interfaces = {
  #     enp0s31f6.useDHCP = true;
  #     wlp2s0.useDHCP = true;
  #   };
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.localtime.enable = true;
  services.geoclue2.enable = true;
  time.timeZone = "America/New_York";

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Reduces performance but makes the battery last a LOT longer
  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.networkmanager.enable = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
  nixpkgs.config.pulseaudio = true;
  users.extraUsers.nhyne.extraGroups = [ "audio" ];

  nixpkgs.config.allowUnfree = true;
  
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    trustedUsers = [ "root" "nhyne" ];
  };

  users.mutableUsers = true;
  users.users.nhyne = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "password";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwxRycY1AvRNiEFOPtd3gerX/T68jHHkvDu1Y4I4vSxmgv9gZTgXMpli78KCwmZHiXoKE7uc1Nd5lVLCiHol4Zk5zNY2zJ7ltogu9KdzGxJK0axmSF5GnP74VNlWU93/0SzNpgH+PahbWyvMcFe4TVyKESVt2JQjXlhc3otutB+zoFXhVdbqVSm46N9NrxbsSyOhjfzjCc09cgc2o2P9fOe0JYwzpDDWQymnQVQ8fl/EzP0MWCje15YxHZjLgrvYE8K9qkUYSxTWYFDvEf8XzPr9Za5D5IDcfXaCgdDzlkn3x1qd5cDQqrhg1H8QqHnKL/imppdQRKyBxySuIDg6lj4SjTC/G/agxBcsCIzPIO/RSdlFWNyFvvIbGtZHYrduIlW8vSVa9qTNWZyIY8jZjRqi0R5Oe27OuRqp/0Egn9+j6ktjfc3cEYufNaPoAjxMK2OEt/bgHVQXEfPDHy33T094/rbIDS/F+q+k7jQCqW4AstRA/CVR3BOX4Isx70Q78= nhyne@nixos
"
    ];
  };

  environment.systemPackages = with pkgs; [
    delete-squashed
    discord
    jetbrains.idea-ultimate
    ngrok
    postman
    siege
    slack
    spotify
    vscode
    zoom
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "21.05"; # Did you read the comment?

}
