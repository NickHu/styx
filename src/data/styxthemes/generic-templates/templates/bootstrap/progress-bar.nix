env:
let
  template =
    { lib, ... }:
    {
      type ? null,
      stripped ? false,
      value,
    }:
    with lib;
    let
      typeClass = optionalString (type != null) "progress-bar-${type}";
      strippedClass = optionalString stripped "progress-bar-striped";
      classes = filter (x: x != "") [
        "progress-bar"
        typeClass
        strippedClass
      ];
    in
    ''
      <div class="progress">
        <div ${lib.template.htmlAttr "class" classes} role="progressbar" aria-valuenow="${toString value}" aria-valuemin="0" aria-valuemax="100" style="width: ${toString value}%"><span class="sr-only">${toString value}% Complete</span></div>
      </div>
    '';
in
template env
