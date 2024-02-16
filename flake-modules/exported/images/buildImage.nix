{name, pkgs, lib, nix2container, config, system, imageSystem, ...}: 
let
  imageConfig._file = ./buildImage.nix;
  imageConfig.options = {
    raw = lib.mkOption {
      description = ''The attrs as passed to nix2container.buildImage
        as `config` arguement.

        Everything in the OCI ImageConfig should be allowed:

        https://github.com/opencontainers/image-spec/blob/8b9d41f48198a7d6d0a5c1a12dc2d1f7f47fc97f/specs-go/v1/config.go#L23
      '';
      type = lib.types.lazyAttrsOf lib.types.unspecified;
    };

    entrypoint = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.listOf lib.types.str
      );
    };
  };
in {
  _file = ./buildImage.nix;

  options = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "The name of the container -- reexported for convenience.";
      default = name;
    };

    result = lib.mkOption {
      type = lib.types.package;
      description = "The result of nix2container.buildImage -- the resulting image.";
    };

    imageConfig = lib.mkOption {
      type = lib.types.submodule imageConfig;
    };
  };

  config = {
    result = nix2container.packages.${imageSystem}.nix2container.buildImage {
      inherit (config) name;
      config = config.imageConfig.raw;
    };

    imageConfig.raw = {
      entrypoint = config.imageConfig.entrypoint;
    };
  };
}