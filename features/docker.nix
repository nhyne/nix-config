{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    #dockerCompat = true;
  };
  virtualisation.docker.enable = true;
}
