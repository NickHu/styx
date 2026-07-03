env: let
  template = {
    lib,
    conf,
    templates,
    ...
  }: {
    item,
    currentPage ? null,
    ...
  }:
    with lib; let
      isCurrent = item:
        (currentPage
          != null
          && currentPage ? breadcrumbs
          && item ? path
          && elem item.path (map (p: p.path) currentPage.breadcrumbs))
        || (currentPage != null && item ? path && currentPage.path == item.path);
      active = optionalString (isCurrent item) (" " + lib.template.htmlAttr "class" "active");
      title = item.navbarTitle or item.title;
      href = lib.template.htmlAttr "href" (templates.url (attrByPath ["url"] item item));
      class = optionalString (item ? navbarClass) (" " + lib.template.htmlAttr "class" item.navbarClass);
    in ''
      <li${active}><a ${href}${class}>${title}</a></li>'';
in
  template env