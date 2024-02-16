{
  perSystem = {pkgs, ...}: {
    n2c.images.basic = {imagePkgs, ...}: {
      imageConfig = {
        entrypoint = ["${imagePkgs.hello}/bin/hello"];
      };
    };
  };
}
