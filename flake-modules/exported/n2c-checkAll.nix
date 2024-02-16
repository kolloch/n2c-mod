{lib, ...}:
{
  perSystem = {config, ...}: {
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