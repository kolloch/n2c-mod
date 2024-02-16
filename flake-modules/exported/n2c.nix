{nix2container, ...}: {
  inputs,
  lib,
  system,
  ...
} @ args: {
  imports = [
    ./n2c-base.nix
    ./n2c-checkAll.nix
  ];

  config._module.args = {
    inherit nix2container;
    nixpkgs = inputs.nixpkgs;
  };

  config.perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages.skopeo-nix2container = nix2container.packages.${system}.skopeo-nix2container;
  };
}
