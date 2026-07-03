env:
let
  template =
    {
      lib,
      templates,
      ...
    }:
    { page }:
    with lib;
    optionalString (page ? extraJS) (lib.mapTemplate templates.tag.script page.extraJS);
in
template env
