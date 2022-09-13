{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url =
      "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-master.url =
      "github:nixos/nixpkgs/master";
    nixos-hardware.url =
      "github:NixOS/nixos-hardware/master";
    home-manager.url =
      "github:nix-community/home-manager/release-22.05";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, nixpkgs-master, ... }:
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
                difftastic = difftastic;
              };
            }
          ] ++ extraModules);
        };
    in {
      nixosConfigurations.server1 = mkHomeMachine ./hosts/server1.nix [ ];

      nixosConfigurations.x1-nhyne = mkHomeMachine ./hosts/x1-nhyne.nix [ ];

      nixosConfigurations.x1-peloton = mkHomeMachine ./hosts/x1-peloton.nix [ ];
    };
}
