{
  description = "nhyne's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager-master.url = "github:nix-community/home-manager/master";
    home-manager.url = "github:nix-community/home-manager/release-24.11";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
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
      # Make configuration for any computer I use in my home office.
      mkHomeMachine =
        configurationNix: extraModules:
        nixpkgs-master.lib.nixosSystem {
          inherit pkgs;
          # Arguments to pass to all modules.
          specialArgs = { inherit inputs; };
          modules = (
            [
              configurationNix
              #              ./features/docker.nix
              home-manager-master.nixosModules.home-manager
              {
                nixpkgs.hostPlatform = "aarch64-linux";
                #                nixpkgs.crossSystem = "aarch64-linux";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                # currently home-manager cross compiling is broken, waiting for the PR below to land
                # https://github.com/nix-community/home-manager/pull/6500
                home-manager.users.nhyne = import ./home.nix {
                  inherit inputs pkgs;
                  isServer = true;
                  #                                  pkgs = import nixpkgs { inherit system; };
                };
              }
              (
                { config, pkgs, ... }:
                {
                  environment.systemPackages = with pkgs; [
                    go # Add Go for building
                    cacert # Ensure CA certificates are available
                  ];

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
                #              home-manager.users.${userName}.nix.package = nixpkgs.lib.mkDefault nixpkgs.legacyPackages.${system}.nix;
                home-manager.users.${userName} = import ./home.nix {
                  pkgs = nixpkgs.legacyPackages.${system};
                  isServer = false;
                };
              }
            ];
          };
        in
        {
          COMP-CDJJ7X690W = defaultMacosSystem;
        };
    in
    {
      nixosConfigurations.raspi = mkHomeMachine ./hosts/raspi.nix [ ./features/docker.nix ];
      nixosConfigurations.x1-nhyne = mkHomeMachine ./hosts/x1-nhyne.nix [ ];

      darwinConfigurations = darwinConfigurations;
    };
}
