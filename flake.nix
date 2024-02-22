{
  inputs = {
    nixpkgs.url = "nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    devshell,
    nix2container,
    pre-commit-hooks-nix,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      withSystem,
      flake-parts-lib,
      ...
    }: let
      exportedModule.default =
        flake-parts-lib.importApply
        ./flake-modules/exported/n2c.nix
        {
          inherit withSystem nix2container;
        };
    in {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      imports = [
        inputs.flake-parts.flakeModules.flakeModules

        ./flake-modules/n2c-checks.nix
        ./flake-modules/nodejs-packages.nix
        ./flake-modules/nodejs-devshell.nix
        ./flake-modules/module-docs.nix
        ./flake-modules/pre-commit.nix
        ./docs/flake-module.nix
        exportedModule.default
        ./flake-modules/n2c-export-json.nix

        # Shared with example template
        ./template/flake-modules/nix-dev.nix
        ./template/flake-modules/images/default.nix
      ];

      debug = true;

      flake.flakeModules = exportedModule;
      flake.templates.default = {
        path = ./template;
        description = "Some example images with n2c-mod.";
      };
    });
}
