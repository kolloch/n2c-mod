{
  perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
    packages.docs = pkgs.buildNpmPackage {
      pname = "docs";
      version = "0.1.0";

      inherit (config.packages) nodejs;

      src = ./.;

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
