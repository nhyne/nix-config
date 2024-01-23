{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-22.11";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, nixpkgs-master, darwin, ... }:
    let
      system = "x86_64-linux";
      difftastic = nixpkgs-master.legacyPackages.${system}.difftastic;
      # Make configuration for any computer I use in my home office.
      mkHomeMachine = configurationNix: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          # Arguments to pass to all modules.
          specialArgs = { inherit system inputs; };
          modules = ([
            configurationNix
            ./features/docker.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nhyne = import ./home.nix {
                inherit inputs system;
                pkgs = import nixpkgs { inherit system; };
                difftastic = difftastic;
              };
            }
          ] ++ extraModules);
        };

      darwinConfigurations = let
        system = "aarch64-darwin";
        userName = "adam.johnson";
        defaultMacosSystem = self.nixos-flake.lib.mkMacosSystem {
#          inherit system;
          nixpkgs.hostPlatform = system;
#          specialArgs = { inherit inputs system; };
          modules = [
            ./systems/darwin.nix
#            home-manager.darwinModules.home-manager
#            {
#              home-manager.useGlobalPkgs = true;
#              home-manager.useUserPackages = true;
#              home-manager.users.${userName} =
#                import ./home.nix { pkgs = nixpkgs.legacyPackages.${system}; };
#            }
          ];
        };
      in { COMP-CDJJ7X690W = defaultMacosSystem; };
    in {
      nixosConfigurations.server1 = mkHomeMachine ./hosts/server1.nix [ ];
      nixosConfigurations.x1-nhyne = mkHomeMachine ./hosts/x1-nhyne.nix [ ];

      darwinConfigurations = darwinConfigurations;
    };
}
