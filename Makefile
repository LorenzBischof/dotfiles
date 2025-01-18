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

.PHONY: switch-override
switch-override: add
	sudo nixos-rebuild switch --flake . --override-input nix-secrets ../nix-secrets

.PHONY: deploy
deploy: add
	nixos-rebuild switch --flake .#nas --target-host nas --use-remote-sudo

.PHONY: dry-build-nas
dry-build-nas: add
	NIXPKGS_ALLOW_INSECURE=1 nixos-rebuild dry-build --flake .#nas --impure
