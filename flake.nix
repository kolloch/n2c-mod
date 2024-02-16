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

        ./flake-modules/nodejs-packages.nix
        ./flake-modules/nodejs-devshell.nix
        ./flake-modules/module-docs.nix
        ./docs/flake-module.nix
        exportedModule.default
        ./flake-modules/n2c-export-json.nix

        # Shared with example template
        ./template/flake-modules/nix-dev.nix
        ./template/flake-modules/images/default.nix
      ];

      debug = true;

      flake.flakeModules = exportedModule;
    });
}
