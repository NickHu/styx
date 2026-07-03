env:
let
  template =
    {
      lib,
      templates,
      ...
    }:
    with lib;
    lib.normalTemplate (page: ''
      <div>
      ${optionalString (page ? title) "<h1>${page.title}</h1>"}
      ${page.content}

      ${optionalString (page ? pages) (templates.bootstrap.pagination { inherit (page) pages index; })}
      </div>
    '');
in
template env
