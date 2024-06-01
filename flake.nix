{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Pull templates from external flake-parts modules
    # The pull happens in CI periodically.
    haskell-flake.url = "github:srid/haskell-flake";
    haskell-flake.flake = false;
    nix-dev-home.url = "github:juspay/nix-dev-home";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = {
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
          };
        };
      };
      flake = {
        templates = rec {
          home-manager = nix-dev-home;
          nix-dev-home = inputs.nix-dev-home.templates.default // {
            # TODO: Ideally, these params should be moved to upstream module.
            # But do that only as the spec stabliizes.
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
        herculesCI.ciSystems = [ "x86_64-linux" ];
      };
    };
}
