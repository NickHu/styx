/*
  library to deal with properties (single key attribute set), and property lists

  Property example:

    { foo = "bar"; }

  Property list example:

    [ { foo = "bar"; } { baz = "buz"; } ]
*/
lib: styxlib:
with lib;
assert assertMsg (hasAttr "utils" styxlib) "styxlib.proplist uses styxlib.utils";
with styxlib.utils;
rec {

  propKey = prop: head (attrNames prop);

  propValue = prop: head (attrValues prop);

  isDefined =
    key: list:
    let
      keys = map propKey list;
    in
    if (length list) > 0 then elem key keys else false;

  getValue = key: list: head (catAttrs key list);

  getProp = key: list: head (filter (x: (propKey x) == key) list);

  removeProp = key: filter (p: (propKey p) != key);

  propMap = f: map (p: f (propKey p) (propValue p));

  propFlatten = foldr (
    p: acc:
    let
      k = propKey p;
    in
    if isDefined k acc && isList (propValue p) && isList (getValue k acc) then
      [ { "${k}" = (propValue p) ++ (getValue k acc); } ] ++ (removeProp k acc)
    else
      [ p ] ++ acc
  ) [ ];
}
