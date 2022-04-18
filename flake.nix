{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/2f06b87f64bc06229e05045853e0876666e1b023";
    nixos-hardware.url = github:NixOS/nixos-hardware/342048461da7fc743e588ee744080c045613a226;
    home-manager.url = "github:nix-community/home-manager/7244c6715cb8f741f3b3e1220a9279e97b2ed8f5";
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
