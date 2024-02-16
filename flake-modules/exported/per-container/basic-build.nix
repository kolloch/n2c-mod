{name, lib, ...}: {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      default = name;
    };
  };
}