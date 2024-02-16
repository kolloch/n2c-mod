{name, pkgs, lib, nix2container, config, system, skopeo-nix2container, imageSystem, ...}: 
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

    load = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Binaries to copy your image to various targets with skopeo.";
    };

    copy = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Binaries to copy your image to various targets with skopeo.";
    };

    imageConfig = lib.mkOption {
      type = lib.types.submodule imageConfig;
    };
  };

  config = let
    image = nix2container.packages.${imageSystem}.nix2container.buildImage {
        inherit (config) name;
        config = config.imageConfig.raw;
      };
  in {
    result = image;

    load = {
      inDocker = pkgs.writeShellScriptBin "copy-to-docker-daemon" ''
        echo "Load image in docker: ${image.imageName}:${image.imageTag}"
        archive=$(mktemp docker-archive-XXXXXXXXXXXXXX.tar)
        trap 'rm -f -- '"$archive" EXIT
        ${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${image} \
          docker-archive:''${archive}:"${image.imageName}:${image.imageTag}"
        docker load <''${archive}
      '';
    };

    copy = {
      toDockerDaemon = pkgs.writeShellScriptBin "copy-to-docker-daemon" ''
        echo "Copy to Docker daemon image ${image.imageName}:${image.imageTag}"
        ${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${image} docker-daemon:${image.imageName}:${image.imageTag} $@
      '';

      toRegistry = pkgs.writeShellScriptBin "copy-to-registry" ''
        echo "Copy to Docker registry image ${image.imageName}:${image.imageTag}"
        ${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${image} docker://${image.imageName}:${image.imageTag} $@
      '';

      to = pkgs.writeShellScriptBin "copy-to" ''
        echo Running skopeo --insecure-policy copy nix:${image} '$@'
        ${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${image} $@
      '';

      toPodman = pkgs.writeShellScriptBin "copy-to-podman" ''
        echo "Copy to podman image ${image.imageName}:${image.imageTag}"
        ${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${image} containers-storage:${image.imageName}:${image.imageTag}
        ${skopeo-nix2container}/bin/skopeo --insecure-policy inspect containers-storage:${image.imageName}:${image.imageTag}
      '';
    };

    imageConfig.raw = {
      entrypoint = config.imageConfig.entrypoint;
    };
  };
}