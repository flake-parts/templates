{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pull templates from external flake-parts modules
    # The pull happens in CI periodically.
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs: {
    templates = rec {
      haskell = haskell-flake;
      haskell-flake = inputs.haskell-flake.templates.example;
    };

    # To make HCI not fail; remove after adding apps or checks.
    packages.x86_64-linux.hello = inputs.nixpkgs.legacyPackages.x86_64-linux.hello;
  };
}
