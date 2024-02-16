{ nix2container, ... }:
{ inputs, lib, system, ...}@args:
{
  imports = [
    ./n2c-base.nix
    ./n2c-checkAll.nix
  ];

  config._module.args = {
    inherit nix2container;
    nixpkgs = inputs.nixpkgs;
  };

  config.perSystem = {pkgs, inputs', ...}: {
    packages.skopeo-nix2container = inputs'.nix2container.packages.skopeo-nix2container;
  };
}