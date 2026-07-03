env:
let
  template = { lib, ... }: attrs: "<link ${lib.htmlAttrs attrs} />\n";
in
template env
