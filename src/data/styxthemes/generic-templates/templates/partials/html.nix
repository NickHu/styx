env:
let
  template =
    {
      templates,
      lib,
      conf,
      html ? { },
      ...
    }:
    args:
    with lib;
    let
      lang =
        html.lang or (if hasAttrByPath [ "html" "lang" ] conf.theme then conf.theme.html.lang else "en");
    in
    ''
      <html ${lib.htmlAttr "lang" lang}>
        ${(templates.partials.head.default args) + (templates.partials.body args)}</html>'';
in
template env
