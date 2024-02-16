{ ...}:
{ flake-parts-lib, lib, ...}:
flake-parts-lib.mkTransposedPerSystemModule {
  name = "n2c";
  option = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submoduleWith {
        modules = [
          ./per-container/basic-build.nix
        ];
      }
    );
    description = "OCI container by name build with nix2container";
    default = { };
  };
  file = ./n2c.nix;
}