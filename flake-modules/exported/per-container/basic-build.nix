{name, lib, ...}: {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      readOnly = true;
      description = "The name of the container -- reexported for convenience.";
    };
  };
}