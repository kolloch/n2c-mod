{ flake-parts-lib, nix2container, lib, ...}:
let
  imagesModule = {pkgs, system, ...}: {
    _file = ./n2c-base.nix;
    options.images = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submoduleWith {
          modules = [
            {
              config._module.args = {
                inherit nix2container system pkgs;
              };
            }
            ./images/buildImage.nix
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
  options.checkAll = lib.mkOption {
    description = ''Whether to add all image, ... builds to the checks of this flake.'';
    type = lib.types.bool;
    default = true;
  };
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, pkgs, system, ... }: {
      options.n2c = lib.mkOption {
        type = lib.types.submoduleWith {
          modules = [ 
            {
              inherit options;
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