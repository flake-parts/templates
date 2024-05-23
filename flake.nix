{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pull templates from external flake-parts modules
    # The pull happens in CI periodically.
    haskell-flake.url = "github:srid/haskell-flake";
    haskell-flake.flake = false;
  };
  outputs = inputs: {
    templates = rec {
      haskell = haskell-flake;
      haskell-flake = {
        description = "Haskell project template, using haskell-flake";
        path = builtins.path { path = inputs.haskell-flake + /example; };
      };
    };

    # To make HCI not fail; remove after adding apps or checks.
    packages.x86_64-linux.hello = inputs.nixpkgs.legacyPackages.x86_64-linux.hello;
  };
}
