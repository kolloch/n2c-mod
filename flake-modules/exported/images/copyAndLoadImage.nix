{
  name,
  pkgs,
  lib,
  nix2container,
  config,
  system,
  skopeo-nix2container,
  imageSystem,
  ...
}: {
  _file = ./copyAndLoadImage.nix;

  options = {
    load = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Binaries to copy your image to various targets with skopeo.";
    };

    copy = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      description = "Binaries to copy your image to various targets with skopeo.";
    };
  };

  config = let
    image = config.result;
  in {
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
  };
}