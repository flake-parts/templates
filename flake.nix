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
        params = {
          cabal-package-name.description = "Name of the Haskell package";
          cabal-package-name.exec = val: ''
            mv example.cabal ${val}.cabal
            sed -i 's/example/${val}/g' ${val}.cabal 
            sed -i 's/example/${val}/g' flake.nix
          '';
        };
      };
    };

    # To make HCI not fail; remove after adding apps or checks.
    packages.x86_64-linux.hello = inputs.nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.aarch64-darwin.default = inputs.nixpkgs.legacyPackages.aarch64-darwin.writeShellApplication {
      name = "default";
      text = ''
        set -x
        nix flake init -t ${inputs.self}#haskell
        echo "# cabal-package-name"
        ${inputs.self.templates.haskell.params.cabal-package-name.patch "my-haskell-project"}
        echo "done!"
      '';
    };
  };
}
