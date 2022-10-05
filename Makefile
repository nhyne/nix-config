.PHONY: mac linux


mac:
	$$(nix build --extra-experimental-features "flakes nix-command"  .#darwinConfigurations.COMP-CDJJ7X690W.system --no-link --json | nix --extra-experimental-features "flakes nix-command" run ${WITHEXP} nixpkgs#jq -- -r '.[].outputs.out')/sw/bin/darwin-rebuild switch --flake .

linux:
	sudo nixos-rebuild switch --flake .#x1-nhyne
