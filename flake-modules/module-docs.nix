{flake-parts-lib, pkgs, lib, inputs, self, ...}: 
let
  eval = flake-parts-lib.evalFlakeModule {
     inputs =  {
      inherit (inputs) nixpkgs;
      inherit self;
     };
    } {
    imports = [
      (import ./exported/n2c.nix { nix2container = inputs.nix2container; })
    ];
  };
in {
  perSystem = { pkgs, config, ...}: {
    checks.modules-docs = config.packages.module-docs-md;
    packages.module-docs-md =
        let
          sources = [
            { name = "${self}"; url = "https://github.com/kolloch/n2c-mod/blob/main"; }
            { name = "${inputs.nixpkgs}"; url = "https://github.com/NixOS/nixpkgs/blob/main"; }
            { name = "${inputs.flake-parts}"; url = "https://github.com/hercules-ci/flake-parts/blob/main"; }
          ];
          rewriteSource = decl:
            let
              prefix = lib.strings.concatStringsSep "/" (lib.lists.take 4 (lib.strings.splitString "/" decl));
              source = lib.lists.findFirst (src: src.name == prefix) {
                url = builtins.throw "${prefix} not found in sources";
               } sources;
              path = lib.strings.removePrefix prefix decl;
              url = "${source.url}${path}";
            in
            { name = url; url = url; };
          transformOptions = opt:
            let 
              rewrittenSource = opt // { declarations = map rewriteSource opt.declarations; };
            in 
              rewrittenSource // {
                visible = builtins.any (p: lib.hasPrefix p opt.name) [ "perSystem.n2c" ];
              };
          options = pkgs.nixosOptionsDoc {
            options = builtins.removeAttrs eval.options [ "_module" ];

            warningsAreErrors = false;

            inherit transformOptions;
          };
        in
        options.optionsCommonMark;
  }; 
}