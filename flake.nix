{
  inputs = {
    nixpkgs.url = "nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Development

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, nixpkgs, flake-parts, devshell }: 
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ... }:
    let
      exportedModule.default = 
        flake-parts-lib.importApply 
          ./flake-modules/exported/n2c.nix 
          { inherit withSystem; };
    in 
    {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      imports = [
        ./flake-modules/nodejs-packages.nix
        ./flake-modules/nodejs-devshell.nix
        ./flake-modules/module-docs.nix
        ./docs/flake-module.nix
        exportedModule.default
        ./flake-modules/exported/n2c-test.nix
      ];

      debug = true;
    });
}