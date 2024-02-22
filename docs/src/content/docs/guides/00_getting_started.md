---
title: Getting Started
description: Getting started with n2c-mod
---

The easiest way to get started is by using [the template](https://github.com/kolloch/n2c-mod/tree/main/template) in a new project:

```console
❯ nix flake init -t github:kolloch/n2c-mod
```

This is a battery included template, so after importing you get

* a `flake.nix`:
  * with [flake.parts](https://flake.parts),
  * [alejandra](https://github.com/kamadorueda/alejandra) as default `nix` formatter,
  * a [devshell](https://github.com/numtide/devshell) with alejandra,
* sample image definitions in `./flake-modules/images`,
* a pre-filled `.gitignore`, and
* `.envrc` for [direnv](https://direnv.net/).

Simply prune away what you don't want.
