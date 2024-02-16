{
  perSystem = {pkgs, ...}: {
    _file = ./basic.nix;
    n2c.images.basic = {imagePkgs, ...}: {
      imageConfig = {
        entrypoint = ["${imagePkgs.hello}/bin/hello"];
      };
    };
  };
}
