/*
Callers:
  - bin/styx
*/
{siteFile}: let
  pkgs = import ./pkgs.nix;
  self = ./.;
  parsers = import ./src/app/parsers.nix { inherit pkgs; };
  styxlib = import ./src/renderers/styxlib.nix {
    inherit pkgs parsers;
    styx = pkgs.styx;
  };
  docslib = import ./src/renderers/docslib.nix { inherit pkgs styxlib; };
  docs = import ./src/renderers/docs/default.nix { inherit pkgs self styxlib docslib; };
in
  docs.site siteFile {extraConf.siteUrl = "http://domain.org";}
