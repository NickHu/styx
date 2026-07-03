env: let
  template = {lib, ...}: {
    heading ? null,
    body ? null,
    footer ? null,
    listGroup ? null,
    type ? "default",
  }:
    with lib; let
      h = optionalString (heading != null) "<div class=\"panel-heading\">${heading}</div>\n";
      b = optionalString (body != null) "<div class=\"panel-body\">${body}</div>\n";
      l = optionalString (listGroup != null) listGroup;
      f = optionalString (footer != null) "<div class=\"panel-footer\">${footer}</div>\n";
    in
      concatStringsSep "" ["<div class=\"panel panel-${type}\">\n" h b l f ''</div>''];
in
  template env