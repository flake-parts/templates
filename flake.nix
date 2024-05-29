{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pull templates from external flake-parts modules
    # The pull happens in CI periodically.
    haskell-flake.url = "github:srid/haskell-flake";
    haskell-flake.flake = false;
    nix-dev-home.url = "github:juspay/nix-dev-home";
  };
  outputs = inputs: {
    templates = rec {
      home-manager = nix-dev-home;
      nix-dev-home = inputs.nix-dev-home.templates.defaut // {
        params = {
          username = {
            name = "Username";
            help = "Your username as shown by by $USER";
            default = "runner";
            required = true;
            files = [
              "flake.nix"
            ];
          };
          full-name = {
            name = "Full Name";
            help = "Your full name for use in Git config";
            default = "John Doe";
            required = true;
            files = [
              "home/default.nix"
            ];
          };
          email = {
            name = "Email";
            help = "Your email for use in Git config";
            default = "johndoe@example.com";
            required = true;
            files = [
              "home/default.nix"
            ];
          };
        };
      };
      haskell = haskell-flake;
      haskell-flake = {
        description = "Haskell project template, using haskell-flake";
        path = builtins.path { path = inputs.haskell-flake + /example; };
        params = {
          cabal-package-name = {
            name = "Package Name";
            help = "Name of the Haskell package";
            default = "example";
            required = false;
            files = [
              "example.cabal"
              "flake.nix"
            ];
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
