{lib, ...}: {
  config.perSystem = {config, pkgs, ...}: {
    checks.n2c-crashtest = pkgs.runCommand "n2c-crashtest" {} ''
      #!${lib.getExe pkgs.bash}

      echo ${lib.escapeShellArg (builtins.toJSON config.n2c)} >$out
    '';
  };
}