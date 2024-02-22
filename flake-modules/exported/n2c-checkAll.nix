{
  lib,
  config,
  flake-parts-lib,
  ...
} @ global: {
  options.perSystem = flake-parts-lib.mkPerSystemOption ({
    config,
    pkgs,
    system,
    ...
  }: {
    options.n2c = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [
          {
            options.check = lib.mkOption {
              description = ''Whether to image builds, ... to the checks of this flake.'';
              default = {};
              type = lib.types.submoduleWith {
                modules = [
                  {
                    options.images = lib.mkOption {
                      description = ''Whether to add image builds to the checks of this flake.'';
                      type = lib.types.bool;
                      default = true;
                    };
                    options.imageActions = lib.mkOption {
                      description = ''Whether to add image actions (from `do`) to the checks of this flake.'';
                      type = lib.types.bool;
                      default = false;
                    };
                  }
                ];
              };
            };
          }
        ];
      };
    };
  });

  config.perSystem = {config, ...}: {
    config.checks = let
      imageToResultCheck = name: value:
        lib.nameValuePair
        "n2c-image-${name}"
        value.result;

      buildImageChecks = lib.mapAttrsToList imageToResultCheck config.n2c.images;

      imageActionsForImage = imageName: value: let
        actionToCheck = imageName: value: category: action:
          lib.nameValuePair
          "n2c-image-${imageName}-${category}-${action}"
          value.do.${category}.${action};
        buildActions = category: actions:
          lib.mapAttrsToList
          (
            action: package:
              actionToCheck imageName value category action
          )
          actions;
        categoryActions =
          lib.mapAttrsToList buildActions value.do;
      in
        lib.lists.flatten categoryActions;

      imageActions = let
        actionsPerImage =
          lib.mapAttrsToList imageActionsForImage config.n2c.images;
      in
        lib.lists.flatten actionsPerImage;

      checks =
        (lib.optionals config.n2c.check.images buildImageChecks)
        ++ (lib.optionals config.n2c.check.imageActions imageActions);
    in
      lib.listToAttrs checks;
  };
}
