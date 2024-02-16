{
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;

    devshells.default = {
      commands = [
        { package = pkgs.alejandra; category = "nix"; }
      ];
    };
  };
}