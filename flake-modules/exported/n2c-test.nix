{lib, ...}: {
  config.perSystem = {config, pkgs, ...}: {
    checks.n2c-crashtest = pkgs.runCommand "n2c-crashtest" {} ''
      echo ${lib.escapeShellArg (builtins.toJSON config.n2c)} >$out
    '';
  };
}