env: let
  template = {
    conf,
    templates,
    ...
  }: {
    to,
    content ? "",
    ...
  } @ args:
    templates.tag.generic ((removeAttrs args ["path" "to"])
      // {
        tag = "a";
        href = templates.url to;
        content =
          if content != ""
          then content
          else to.title;
      });
in
  template env