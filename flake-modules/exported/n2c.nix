{ nix2container, ... }:
{ lib, system, ...}@args:
{
  imports = [
    ./n2c-base.nix
    ./n2c-checkAll.nix
  ];
  config._module.args = {
    inherit nix2container;
  };
}