.PHONY: test

test:
	nix --extra-experimental-features 'nix-command flakes' run nixpkgs#bats -- tests/
