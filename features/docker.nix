{ pkgs, ... }: {
  virtualisation.docker.enable = true;

  users.users.nhyne = {
    extraGroups = [ "lxd" "docker" ];
  };
}
