/*
This function sits at the root of the `styx` derivation for compatibility reasons
when styx is invoked with 'import pkgs.styx'

Therefore, the entire source tree is copied into the derivation.

Callers:
  - site.nix (import pkgs.styx) -- musn't be impure within this flake, e.g. tests
*/
{
  themes ? [],
  config ? [],
  env ? {},
  pkgs ? import ./pkgs.nix,
  debug ? false,
}: let
  parsers = import ./src/app/parsers.nix { inherit pkgs; };
  styxlib = import ./src/renderers/styxlib.nix {
    inherit pkgs parsers;
    styx = pkgs.styx;
  };

  loaded = styxlib.themes.load {
    lib = styxlib;
    inherit themes env config;
  };
in
  pkgs.lib.traceIf debug "site config: ${pkgs.lib.generators.toPretty {} loaded.lib.config}" {
    inherit (loaded) lib conf decls;
    themes = loaded;
  }
