env: let
  template = {
    lib,
    pages,
    templates,
    ...
  }: args:
    with lib;
      optionalString (pages ? feed)
      (templates.tag.link-atom {
        href = templates.url pages.feed;
      });
in
  template env