{
  description = "Nix darwin config flake";

  inputs = {
    # Our primary nixpkgs repo. Modify with caution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # sops
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Macos Modules
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    overlays = import ./overlays {inherit inputs outputs;};
    darwinConfigurations = {
      m1mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        specialArgs = {inherit inputs outputs;};
        modules = let
          defaults = {pkgs, ...}: {
            _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {inherit (pkgs.stdenv.targetPlatform) system;};
          };
        in [
          defaults
          ./machines/m1mac/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
