# utilities
lib: with lib; {
  find =
    criteria: list:
    let
      subset =
        sub: super:
        foldr (a: b: a && b) true (
          mapAttrsToList (
            k: v:
            let
              v' = getAttr k super;
              matching = if isFunction v then v v' else v == v';
            in
            hasAttr k super && matching
          ) sub
        );
      matches = filter (subset criteria) list;
    in
    if matches == [ ] then
      throw ''
        No items matched the following find criteria:
        ---
        ${prettyNix criteria}
        ---
      ''
    else
      head matches;

  chunksOf =
    k:
    let
      f = ys: xs: if xs == [ ] then ys else f (ys ++ [ (take k xs) ]) (drop k xs);
    in
    f [ ];

  merge = foldl' recursiveUpdate { };

  sortBy =
    attribute: order:
    sort (
      a: b:
      if order == "asc" then
        a."${attribute}" < b."${attribute}"
      else if order == "dsc" then
        a."${attribute}" > b."${attribute}"
      else
        abort "Sort order must be 'asc' or 'dsc'"
    );

  dirContains =
    dir: path:
    let
      pathArray = filter (x: x != "") (splitString "/" path);
      loop =
        base: path:
        let
          contents = readDir base;
        in
        if hasAttrByPath [ (head path) ] contents then
          if length path > 1 then loop (base + "/${head path}") (tail path) else true
        else
          false;
    in
    loop dir pathArray;

  setToList =
    s:
    let
      f =
        path: set:
        map (
          key:
          let
            value = set.${key};
            newPath = path ++ [ key ];
            pathString = concatStringsSep "." newPath;
          in
          if isAttrs value then f newPath value else { "${pathString}" = value; }
        ) (attrNames set);
    in
    flatten (f [ ] s);

  isPath = x: (!isAttrs x) && types.path.check x;

  importApply =
    file: arg:
    let
      f = import file;
    in
    if isFunction f then f arg else f;

  prettyNix =
    expr:
    let
      indent = n: concatStrings (genList (_: " ") (n * 2));
      isLit = x: isAttrs x && x ? _type && x._type == "literalExpression";
      loop =
        n: x:
        if isString x then
          ''"${replaceStrings [ ''"'' ] [ ''\"'' ] x}"''
        else if isInt x then
          toString x
        else if (x == null) then
          "null"
        else if isList x then
          "[ ${concatStringsSep " " (map (loop n) x)} ]"
        else if isBool x then
          toJSON x
        else if x == { } then
          "{ }"
        else if isLit x then
          x.text
        else if isDerivation x then
          "(build of ${x.name})"
        else if isAttrs x then
          ''
            {
            ${indent (n + 1)}${
              concatStringsSep "\n${indent (n + 1)}" (
                mapAttrsToList (
                  k: v:
                  let
                    k' =
                      if (match "^(.+)[.](.+)$" k) != null || (match "^(.+)[ \t\r\n](.+)$" k) != null then
                        ''"${k}"''
                      else
                        k;
                  in
                  "${k'} = ${loop (n + 1) v};"
                ) x
              )
            }
            ${indent n}}''
        else if isFunction x then
          "<function>"
        else if (typeOf x == "path") then
          "`${toString x}`"
        else
          "";
    in
    loop 0 expr;
}
