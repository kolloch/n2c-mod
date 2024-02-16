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
      default = null;
    };

    cmd = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.listOf lib.types.str
      );
      default = null;
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
      description = ''
        The JSON descriptor for the resulting image -
        the return value of the `nix2container.buildImage`.
      '';
    };

    imageConfig = lib.mkOption {
      type = lib.types.submodule imageConfig;
      description = ''The OCI image config.'';
    };

    copyToRoot = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''
        A list of derivations copied in the image root directory.
        
        Store path prefixes /nix/store/hash-path are removed, in order to relocate them at the image /.
      '';
      default = [];
    };
  };

  config = {
    result = nix2container.packages.${imageSystem}.nix2container.buildImage {
      inherit (config) name copyToRoot;
      config = config.imageConfig.raw;
    };

    imageConfig.raw = {
      entrypoint = config.imageConfig.entrypoint;
      cmd = config.imageConfig.cmd;
    };
  };
}