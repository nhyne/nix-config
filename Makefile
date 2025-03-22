.PHONY: mac linux raspi_iso wsl_home

mac:
	nix run nix-darwin -- switch --flake .

linux:
	sudo nixos-rebuild switch --flake .#x1-nhyne

# impure build is to access env vars for secrets
raspi_iso:
	nix build --impure --show-trace --keep-going -j4 --cores 4 '.#nixosConfigurations.raspi.config.system.build.sdImage'

wsl_home:
	home-manager switch -f ./home.nix