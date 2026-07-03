env:
let
  template =
    {
      lib,
      conf,
      templates,
      ...
    }:
    {
      items,
      align ? null,
      currentPage ? null,
      ...
    }:
    with lib;
    let
      extraClasses = optionalString (align != null) " navbar-${align}";
      isCurrent =
        item:
        (
          currentPage != null
          && currentPage ? breadcrumbs
          && item ? path
          && elem item.path (map (p: p.path) currentPage.breadcrumbs)
        )
        || (currentPage != null && item ? path && currentPage.path == item.path);
    in
    ''
      <ul class="nav navbar-nav${extraClasses}">
      ${lib.mapTemplate (
        item:
        if isString item then item else templates.bootstrap.navbar.nav_item { inherit item currentPage; }
      ) items}
      </ul>'';
in
template env
