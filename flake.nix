{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/release-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-24.11";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
      nixpkgs-master,
      darwin,
      ...
    }:
    let
      #      system = "aarch64-linux";
      #      pkgs = (import nixpkgs { system = "x86_64-linux"; crossSystem = "aarch64-linux"; });
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        crossSystem = {
          config = "aarch64-linux";
        };
      };
      # Make configuration for any computer I use in my home office.
      mkHomeMachine =
        configurationNix: extraModules:
        nixpkgs.lib.nixosSystem {
          #          inherit system;
          inherit pkgs;
          # Arguments to pass to all modules.
          specialArgs = { inherit inputs; };
          modules = (
            [
              #              (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
              configurationNix
              #              ./features/docker.nix
              home-manager.nixosModules.home-manager
              {
                nixpkgs.hostPlatform = "aarch64-linux";
                #                nixpkgs.crossSystem = "aarch64-linux";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                #                home-manager.users.nhyne = import ./home.nix {
                #                  inherit inputs system pkgs;
                #                  pkgs = import nixpkgs { inherit system; };
                #                };
              }
            ]
            ++ extraModules
          );
        };

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          userName = "adam.johnson";
          defaultMacosSystem = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit inputs system; };
            modules = [
              ./systems/darwin.nix
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                #              home-manager.users.${userName}.nix.package = nixpkgs.lib.mkDefault nixpkgs.legacyPackages.${system}.nix;
                home-manager.users.${userName} = import ./home.nix { pkgs = nixpkgs.legacyPackages.${system}; };
                #              home-manager.extraSpecialArgs =;
              }
            ];
          };
        in
        {
          COMP-CDJJ7X690W = defaultMacosSystem;
        };
    in
    {
      nixosConfigurations.raspi = mkHomeMachine ./hosts/raspi.nix [ ];
      nixosConfigurations.x1-nhyne = mkHomeMachine ./hosts/x1-nhyne.nix [ ];

      darwinConfigurations = darwinConfigurations;
    };
}
