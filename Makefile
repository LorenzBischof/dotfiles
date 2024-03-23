.PHONY: all
all: switch

.PHONY: update
update:
	nix flake update
	sudo nixos-rebuild switch --flake .

.PHONY: switch
switch:
	sudo nixos-rebuild switch --flake .
