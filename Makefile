.PHONY: mac linux

mac:
	nix run nix-darwin -- switch --flake .

linux:
	sudo nixos-rebuild switch --flake .#x1-nhyne
