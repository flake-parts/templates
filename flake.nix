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
        # Philosophy:
        # Templates should remain compatible with `nix flake init` (ie., the 'placeholders' as is should still build)
        # The params, then, simply replace the placeholders
        params = {
          cabal-package-name = {
            name = "Package Name";
            help = "Name of the Haskell package";
            # TODO: Sometimes the default is dynamically detected?
            # eg.: $USER
            default = "example";
            required = false;
            files = [
              "example.cabal"
              "flake.nix"
            ];
            # TODO: Is this a security issue?
            # Can we do away with arbitrary shell commands?
            # Use cases:
            # - Placeholder replacements
            # - Uncomment? https://github.com/juspay/nix-dev-home/issues/37
            # - *Required* params
            
            exec = ''
              mv example.cabal ''${VALUE}.cabal
              sed -i 's/example/''${VALUE}/g' ''${VALUE}.cabal 
              sed -i 's/example/''${VALUE}/g' flake.nix
            '';
          };
        };
      };
    };

    formatter.aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;

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
