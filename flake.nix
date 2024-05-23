{
  inputs = {
    # Pull templates from external flake-parts modules
    # The pull happens in CI periodically.
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs: {
    templates = rec {
      haskell = haskell-flake;
      haskell-flake = inputs.haskell-flake.templates.example;
    };
  };
}
