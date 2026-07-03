env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    with lib;
    {
      id ? "navbar",
      inverted ? false,
      fluid ? false,
      extraClasses ? [ ],
      brand ? templates.bootstrap.navbar.brand,
      content ? [ ],
    }@args:
    let
      baseClass = if inverted then "navbar-inverse" else "navbar-default";
      class = lib.htmlAttr "class" (
        [
          "navbar"
          baseClass
        ]
        ++ extraClasses
      );
    in
    ''
      <nav ${class} id="${id}">
      <div class="container${optionalString fluid "-fluid"}">
      ${templates.bootstrap.navbar.head { inherit id brand; }}
      <div class="collapse navbar-collapse" id="${id}-collapse">
      ${concatStringsSep "\n" content}
      </div>
      </div>
      </nav>
    '';
in
template env
