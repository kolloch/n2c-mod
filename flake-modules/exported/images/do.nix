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
  _file = ./do.nix;

  options = {
    do.copy = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [
          {
            options.toDockerDaemon = lib.mkOption {
              type = lib.types.package;
              description = ''
                Copy the image to your default docker daemon.
              '';
            };
            options.toPodman = lib.mkOption {
              type = lib.types.package;
              description = ''
                Copy the image to podman store.
              '';
            };
            options.toRegistry = lib.mkOption {
              type = lib.types.package;
              description = ''
                Copy the image to its canonical registry
                with matching `imageName`/`imageTag`.
              '';
            };
            options.to = lib.mkOption {
              type = lib.types.package;
              description = ''
                Invoke scopeo copy without specifying the
                target yet -- provide your own!
              '';
            };
          }
        ];
      };
      description = "Copy your image to various targets with skopeo.";
    };
    do.run = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [
          {
            options.interactivelyInDocker = lib.mkOption {
              type = lib.types.package;
              description = ''
                Load the image and run it interactively (`run -it`) in
                the locally installed docker.
              '';
            };
            options.interactivelyWithPodman = lib.mkOption {
              type = lib.types.package;
              description = ''
                Load the image and run it interactively (`run -it`) in
                the locally installed podman.
              '';
            };
          }
        ];
      };
      description = "Binaries to run your image.";
    };
  };

  config = let
    image = config.result;
    discover_docker_context = ''
      # skopeo does NOT pick up docker contexts by default
      SKOPEO_DOCKER_DEST=()
      SKOPEO_DOCKER_DEST+=(\
        --dest-daemon-host\
        $(docker context inspect -f '{{.Endpoints.docker.Host}}' | head -n 1)\
      )

      # $(docker context inspect -f '{{.Endpoints.docker.SkipTLSVerify}}')
    '';
  in {
    do.copy = {
      toDockerDaemon = pkgs.writeShellScriptBin "copy-to-docker-daemon" ''
        ${discover_docker_context}
        echo "Copy to Docker daemon image ${image.imageName}:${image.imageTag}"
        ${skopeo-nix2container}/bin/skopeo \
          --insecure-policy copy nix:${image} \
          ''${SKOPEO_DOCKER_DEST[@]} \
          docker-daemon:${image.imageName}:${image.imageTag} $@
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

    do.run = {
      interactivelyInDocker = pkgs.writeShellScriptBin "run-in-docker-daemon" ''
        source ${config.do.copy.toDockerDaemon}/bin/copy-to-docker-daemon &&\
          docker run -it ${image.imageName}:${image.imageTag} $@
      '';
      interactivelyWithPodman = pkgs.writeShellScriptBin "run-with-podman" ''
        source ${config.do.copy.toPodman}/bin/copy-to-podman &&\
          podman run -it ${image.imageName}:${image.imageTag} $@
      '';
    };
  };
}
