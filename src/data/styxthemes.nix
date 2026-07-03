{ pkgs }:
let
  l = pkgs.lib // builtins;
  themeDirs = l.filterAttrs (_: t: t == "directory") (l.readDir ./styxthemes);
in
l.mapAttrs (name: _: ./styxthemes + "/${name}") themeDirs
