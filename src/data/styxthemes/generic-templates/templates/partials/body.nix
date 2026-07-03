env: let
  template = {
    templates,
    lib,
    ...
  }: {page, ...} @ args:
    with lib; let
      id = optionalString (hasAttrByPath ["body" "id"] page) " ${lib.template.htmlAttr "id" page.body.id}";
      class = optionalString (hasAttrByPath ["body" "class"] page) " ${lib.template.htmlAttr "class" page.body.class}";
    in ''
      <body${id}${class}>
      ${
        (templates.partials.content-pre args)
        + (templates.partials.content args)
        + (templates.partials.content-post args)
        + (templates.partials.js args)
      }</body>
    '';
in
  template env