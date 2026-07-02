/*
Callers:
  - site.nix (import pkgs.styx.themes) -- musn't be impure within this flake, e.g. tests
  - bin/styx
*/
let
  pkgs = import ./pkgs.nix;
in
  import ./src/data/styxthemes.nix { inherit pkgs; }
