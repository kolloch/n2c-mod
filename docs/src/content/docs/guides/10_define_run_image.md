---
title: Define/Run Image
description: Define a basic image, build, and run it.
---

You can define a simple image by simply referencing a package
from the entry point. The referenced packages will automatically
end up in the image!

```nix
# ./flake-modules/basic-image-flake-module.nix
{
  # Provide builders for all systems of your flake
  perSystem = {
    # `imageSystem`, `imagePkgs` automatically refer to the target architecture 
    # of your image.
    # By default, the corresponding Linux platform for Darwin/Mac OS.
    n2c.images.basic = {imageSystem, imagePkgs, ...}: {
      imageConfig = {
        # As usual with nix, all dependencies are included automatically.
        # But you can also explicitly decide what to put into which layer!
        entrypoint = ["${imagePkgs.hello}/bin/hello"];
      };
    };
  };
}
```

## Import in your flake.nix

Make sure that you also add this flake module to the imports in your flake.nix:

```nix
{
    # ... 
    imports = [
        # ...
        ./flake-modules/basic-image-flake-module.nix
    ];
}
```

And add it to version control with `git add` if you use `git` so that it is
picked up.

## Building your image

By default, all image builds are added to the `checks` of the flake. Therefore,
you'll check whether your image builds (and potentially other things in your flake)
with:

```console
❯ nix flake check
```

You can also build your image explicitly by name:

```console
❯ nix build .\#n2c.aarch64-darwin.images.basic.result
❯ nix build .\#n2c.x86_64-linux.images.basic.result
... other architectures ...
```

## Run

Build and run it in docker:

```console
❯ nix run .\#n2c.aarch64-darwin.images.basic.do.run.interactivelyInDocker
❯ nix run .\#n2c.x86_64-linux.images.basic.do.run.interactivelyInDocker
... other architectures ...
```

Or podman:

```console
❯ nix run .\#n2c.aarch64-darwin.images.basic.do.run.interactivelyWithPodman
❯ nix run .\#n2c.x86_64-linux.images.basic.do.run.interactivelyWithPodman
... other architectures ...
```
