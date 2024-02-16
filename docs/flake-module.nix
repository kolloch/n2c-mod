{pkgs, ...}: {
  perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
    checks = config.packages;

    packages.docs-src = let 
        cleanedSource = pkgs.nix-gitignore.gitignoreSource [] ./.;
        frontMatter = ''
        ---
        title: Options Reference
        ---
        '';
      in pkgs.runCommand "docs-src" {} ''
          set -x
          mkdir -p "$out/src/content/docs/reference"
          cp -vR ${cleanedSource}/* $out
          find $out
          md="$out/src/content/docs/reference/options.md"
          {
            echo ${lib.escapeShellArg frontMatter}
            cat ${config.packages.module-docs-md}
          } >$md
        '';

    packages.docs = pkgs.buildNpmPackage {
      pname = "docs";
      version = "0.1.0";

      inherit (config.packages) nodejs;

      src = config.packages.docs-src;

      buildInputs = [
        pkgs.vips
      ];

      nativeBuildInputs = [
        pkgs.pkg-config
      ];

      installPhase = ''
        runHook preInstall
        cp -pr --reflink=auto dist $out/
        runHook postInstall
      '';

      npmDepsHash = "sha256-iyz7+GeVYNDa0cLlz8PGmTNAQVetnt87ndfP0vUjxLw=";
    };
  };
}
