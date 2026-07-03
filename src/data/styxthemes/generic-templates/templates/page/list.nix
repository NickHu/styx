env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    lib.normalTemplate (page: "<li>${templates.tag.ilink { to = page; }}</li>");
in
template env
