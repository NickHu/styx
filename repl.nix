# Usage: nix repl ./repl.nix
let
  flake = builtins.getFlake (toString ./.);
  system = builtins.currentSystem;
  l = flake.inputs.nixpkgs.lib;
  pretty = l.generators.toPretty {};
  out = flake.outputs.${system} or flake.outputs;
in
  l.trace "inputs: ${pretty (l.attrNames flake.inputs)}"
  l.trace "outputs: ${pretty (l.attrNames out)}"
  { inherit (flake) inputs; inherit out; }
