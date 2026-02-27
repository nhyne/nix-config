{
  description = "nhyne's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager-master.url = "github:nix-community/home-manager/master";
    home-manager.url = "github:nix-community/home-manager/release-25.11";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      home-manager-master,
      nixpkgs,
      nixpkgs-master,
      darwin,
      ...
    }:
    let
      pkgs = import nixpkgs-master {
        system = "x86_64-linux";
        crossSystem = {
          config = "aarch64-linux";
        };
      };
      mkHomeMachine =
        configurationNix: extraModules:
        nixpkgs-master.lib.nixosSystem {
          inherit pkgs;
          # Arguments to pass to all modules.
          specialArgs = { inherit inputs; };
          modules = (
            [
              configurationNix
              home-manager-master.nixosModules.home-manager
              {
                nixpkgs.hostPlatform = "aarch64-linux";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.nhyne = import ./home.nix {
                  inherit inputs pkgs;
                  isServer = true;
                };
              }
              (
                { config, pkgs, ... }:
                {
                  environment.variables = {
                    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                    GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                  };
                }
              )
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
                home-manager.backupFileExtension = "backup";
                home-manager.users.${userName} = import ./home.nix {
                  pkgs = nixpkgs.legacyPackages.${system};
                  masterpkgs = import nixpkgs-master {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  isServer = false;
                };
              }
            ];
          };
        in
        {
          COMP-CDJJ7X690W = defaultMacosSystem;
          COMP-D7JNF3Q2K3 = defaultMacosSystem;
        };
    in
    {
      nixosConfigurations.raspi = mkHomeMachine ./hosts/raspi.nix [ ./features/docker.nix ];
      nixosConfigurations.x1-nhyne = mkHomeMachine ./hosts/x1-nhyne.nix [ ];

      darwinConfigurations = darwinConfigurations;
    };
}
