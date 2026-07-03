env:
let
  template =
    { lib, ... }:
    lib.template.normalTemplate {
      content = ''
        <div>
          <h1>Page not found, Error 404</h1>
        </div>
      '';
      title = "404";
    };
in
template env
