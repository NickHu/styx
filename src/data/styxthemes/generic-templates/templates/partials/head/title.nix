env:
let
  template =
    {
      lib,
      conf,
      ...
    }:
    with lib;
    { page, ... }: ''
      <title>${page.title}${
        optionalString (hasAttrByPath [ "theme" "site" "title" ] conf) " - ${conf.theme.site.title}"
      }</title>
    '';
in
template env
