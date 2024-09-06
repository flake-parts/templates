# `flake-parts` templates

A registry of various `flake-parts` templates

> [!WARNING] 
> This repo is experimental. Do not promulgate *until* [the GA milestone](https://github.com/flake-parts/templates/milestone/1) is complete. The author (Srid) who originally proposed this is now exploring templates in [`om init`](https://omnix.page/om/init.html).

## Usage

There are two ways to use these templates, the first of which should be preferred:

### flakreate

To initialize a template using [flakreate](https://github.com/juspay/flakreate):

```sh
nix run github:juspay/flakreate ~/myproject
cd ~/myproject
```

This is an interactive app that allows you to choose a template and (optionally) fill in the necessary parameters for the generated project.

### `nix flake init`

To initialize a template using just the `nix` command, run:

```sh
mkdir myproject && cd myproject
TEMPLATE=$(nix flake show github:flake-parts/templates --json | jq -r '.templates | keys[]' | fzf)
nix flake init -t github:flake-parts/templates#${TEMPLATE}
```
