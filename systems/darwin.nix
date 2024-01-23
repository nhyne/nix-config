{ config, pkgs, inputs, system, ... }:

{
#  nix = {
#    nixPath =
#      [ "nixpkgs=${inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
#    registry.nixpkgs.flake =
#      inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
#    extraOptions = ''
#      extra-platforms = aarch64-darwin x86_64-darwin
#      experimental-features = nix-command flakes
#    '';
#    settings = {
#      extra-trusted-substituters = [ "https://cache.floxdev.com" ];
#      extra-trusted-public-keys =
#        [ "flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0=" ];
#    };
#  };
#
#  nixpkgs.config.allowBroken = true;
#  nixpkgs.config.allowUnfree = true;
#
  # For home-manager to work.
  users.users."adam.johnson".name = "adam.johnson";
  users.users."adam.johnson".home = "/Users/adam.johnson";

  environment.systemPackages = with pkgs; [
    hound
    #mutagen
    vscode
    #pre-commit
    yubikey-manager
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
