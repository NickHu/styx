env:
let
  template = { lib, ... }: { src, ... }@attrs: "<script ${lib.template.htmlAttrs attrs}></script>\n";
in
template env
