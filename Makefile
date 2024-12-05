.PHONY: all
all: switch

.PHONY: add
add:
	git add -N .

.PHONY: update
update:
	nix flake update

.PHONY: switch
switch: add
	sudo nixos-rebuild switch --flake .

.PHONY: deploy
deploy: add
	nixos-rebuild switch --flake .#nas --target-host nas --use-remote-sudo
