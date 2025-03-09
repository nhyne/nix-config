.PHONY: mac linux

mac:
	nix run nix-darwin -- switch --flake .

linux:
	sudo nixos-rebuild switch --flake .#x1-nhyne

raspi_iso:
	nix build --show-trace '.#nixosConfigurations.raspi.config.system.build.sdImage' | cachix push nhyne
