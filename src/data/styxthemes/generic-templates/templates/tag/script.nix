env:
let
  template = { lib, ... }: { src, ... }@attrs: "<script ${lib.htmlAttrs attrs}></script>\n";
in
template env
