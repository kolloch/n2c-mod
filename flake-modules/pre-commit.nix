{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
  ];

  perSystem = {config, ...}: {
    pre-commit.check.enable = true;

    pre-commit.settings.hooks.alejandra.enable = true;

    devshells.default = {
      devshell.startup.pre-commit.text = config.pre-commit.installationScript;
    };
  };
}
