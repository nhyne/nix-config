{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/0f316e4d72daed659233817ffe52bf08e081b5de";
    nixos-hardware.url = github:NixOS/nixos-hardware/342048461da7fc743e588ee744080c045613a226;
    home-manager.url = "github:nix-community/home-manager/039f786e609fdb3cfd9c5520ff3791750c3eaebf";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs; };
        modules = ([
          # System configuration
          configurationNix

          # Features common to all of my machines
          ./features/docker.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nhyne = import ./home.nix {
              inherit inputs system;
              pkgs = import nixpkgs { inherit system; };
            };
          }
        ] ++ extraModules);
      };
    in
    {
      nixosConfigurations.server1 = mkHomeMachine
        ./hosts/server1.nix [];

      nixosConfigurations.x1-nhyne = mkHomeMachine
        ./hosts/x1-nhyne.nix [];

      nixosConfigurations.nvme = mkHomeMachine
        ./hosts/nvme.nix [];

      nixosConfigurations.x1-peloton = mkHomeMachine
        ./hosts/x1-peloton.nix [];
    };
}
