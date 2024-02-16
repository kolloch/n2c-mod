{
  perSystem = {pkgs, ...}: {
    _file = ./basic.nix;
    n2c.images.basic = {
      imageConfig = {
        entrypoint = ["${pkgs.hello}/bin/hello"];
      };
    };
  };
}