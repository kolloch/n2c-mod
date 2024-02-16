{ flake-parts-lib, nixpkgs, nix2container, lib, ...}:
let
  imagesModule = {pkgs, system, ...}: {
    _file = ./n2c-base.nix;
    options.images = let
      skopeo-nix2container = nix2container.packages.${system}.skopeo-nix2container;
      imageSystem = 
        if (lib.hasSuffix "-darwin" system)
        then "${lib.removeSuffix "-darwin" system}-linux"
        else system;
      imagePkgs = nixpkgs.legacyPackages.${imageSystem};
    in lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submoduleWith {
          modules = [
            {
              config._module.args = {
                inherit nix2container system pkgs skopeo-nix2container imageSystem imagePkgs;
              };
            }
            ./images/buildImage.nix
            ./images/copyAndLoadImage.nix
          ];
        }
      );
      description = ''
        Exposes options for invoking 
        nix2container.buildImage.
      '';
      default = {};
    };
  };
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, pkgs, system, ... }: {
      options.n2c = lib.mkOption {
        type = lib.types.submoduleWith {
          modules = [ 
            {
              config._module.args = {
                inherit nix2container system pkgs;
              };
              _file = ./n2c-base.nix;
            } 
            imagesModule
          ];
        };
        description = ''
          Build archive-less docker images with nix2container!

          Exposes low/high-level nix2container functionality as options.
        '';
        default = { };
      };
    });
  };

  config.transposition.n2c = {};
}