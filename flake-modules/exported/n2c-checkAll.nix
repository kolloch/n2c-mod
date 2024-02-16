{lib, ...}:
{
  perSystem = {config, ...}: {
    options.n2c.checkAll = lib.mkOption {
      description = ''Whether to add all image, ... builds to the checks of this flake.'';
      type = lib.types.bool;
      default = true;
    };

    config = lib.mkIf config.n2c.checkAll {
      checks = let
        imageToCheck = name: value: 
          lib.nameValuePair
            "n2c-image-${name}"
            value.result;      
      in
      lib.mapAttrs' imageToCheck config.n2c.images;
    };
  };
}