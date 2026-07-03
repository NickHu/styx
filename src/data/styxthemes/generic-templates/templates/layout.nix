env: let
  template = {templates, ...}: page:
    templates.partials.doctype
    + templates.partials.html {inherit page;};
in
  template env