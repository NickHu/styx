env: let
  template = {
    templates,
    lib,
    ...
  }:
    lib.template.normalTemplate (
      page: "<li>${templates.tag.ilink {to = page;}}</li>"
    );
in
  template env