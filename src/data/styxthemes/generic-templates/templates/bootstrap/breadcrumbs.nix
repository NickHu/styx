env:
let
  template =
    {
      lib,
      conf,
      templates,
      ...
    }:
    page:
    with lib;
    optionalString (page ? breadcrumbs) ''
      <ol class="breadcrumb">
      ${lib.mapTemplate (
        p:
        "  <li>${
            templates.tag.ilink {
              content = p.breadcrumbTitle or p.title;
              to = p;
            }
          }</li>"
      ) page.breadcrumbs}
        <li class="active">${page.breadcrumbTitle or page.title}</li>
      </ol>
    '';
in
template env
