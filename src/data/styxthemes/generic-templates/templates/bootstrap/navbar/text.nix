env:
let
  template =
    { lib, ... }:
    with lib;
    {
      content,
      extraClasses ? [ ],
      align ? null,
      ...
    }:
    let
      alignClass = optional (align == "right" || align == "left") "navbar-${align}";
      class = lib.htmlAttr "class" ([ "navbar-text" ] ++ alignClass ++ extraClasses);
    in
    ''
      <p ${class}>${content}</p>
    '';
in
template env
