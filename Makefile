.PHONY: mac


mac:
	nix build .#darwinConfigurations.$(hostname).system
	./result/sw/bin/darwin-rebuild switch --flake .
