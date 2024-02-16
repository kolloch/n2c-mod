{
  perSystem = {pkgs, lib, ...}: {
    n2c.images.bash = {imagePkgs, ...}: {
      imageConfig = {
        cmd = ["/bin/bash"];
      };

      copyToRoot = [
        # When we want tools in /, we need to symlink them in order to
        # still have libraries in /nix/store. This behavior differs from
        # dockerTools.buildImage but this allows to avoid having files
        # in both / and /nix/store.
        (imagePkgs.buildEnv {
          name = "root";
          paths = [ imagePkgs.bashInteractive imagePkgs.coreutils ];
          pathsToLink = [ "/bin" ];
        })
      ];
    };
  };
}