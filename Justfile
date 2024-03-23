switch:
	sudo nixos-rebuild switch --flake .

update:
	nix flake update
	sudo nixos-rebuild switch --flake .
