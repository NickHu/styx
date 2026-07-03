env:
let
  template = { lib, ... }: attrs: "<link ${lib.template.htmlAttrs attrs} />\n";
in
template env
