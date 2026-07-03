env:
let
  template =
    { templates, ... }:
    attrs:
    templates.tag.link (
      {
        rel = "alternate";
        type = "application/atom+xml";
      }
      // attrs
    );
in
template env
