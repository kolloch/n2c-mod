{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {pkgs, config, ...}: {
    formatter = pkgs.alejandra;

    devshells.default = {
      commands = [
        {
          package = config.formatter;
          category = "nix";
        }
      ];
    };
  };
}
