# Page functions
lib: styxlib:
with lib;
with styxlib.utils;
rec {
  mkSplitPagePath =
    {
      index,
      pre,
      post ? ".html",
    }:
    if index == 1 then "${pre}${post}" else "${pre}-${toString index}${post}";

  mkSplitCustom =
    {
      data,
      pageFn,
    }:
    let
      loop =
        index: data: pages:
        let
          index' = index + 1;
          inherit ((pageFn index (head data))) itemsNb;
          items = take itemsNb data;
          pages' = pages ++ [ ((removeAttrs (pageFn index data) [ "itemsNb" ]) // { inherit index items; }) ];
          data' = drop itemsNb data;
        in
        if data == [ ] then pages else loop index' data' pages';
      pages = loop 1 data [ ];
    in
    map (p: p // { inherit pages; }) pages;

  mkSplit =
    {
      basePath,
      itemsPerPage,
      data,
      ...
    }@args:
    let
      extraArgs = removeAttrs args [
        "basePath"
        "itemsPerPage"
        "data"
      ];
    in
    mkSplitCustom {
      inherit data;
      pageFn =
        index: data:
        extraArgs
        // {
          path = mkSplitPagePath {
            inherit index;
            pre = basePath;
          };
          itemsNb = itemsPerPage;
        };
    };

  mkPageList =
    {
      data,
      pathPrefix ? "",
      pageFn ? (data: { path = "${pathPrefix}${data.fileData.basename}.html"; }),
      ...
    }@args:
    let
      extraArgs = removeAttrs args [
        "data"
        "pathPrefix"
        "pageFn"
      ];
      entries =
        if isAttrs data then
          mapAttrsToList (name: value: value // { _attrName = name; }) data
        else
          map (value: value) data;
      list = map (entry: extraArgs // (removeAttrs entry [ "_attrName" ]) // (pageFn entry)) entries;
      named = foldl' (
        acc: entry:
        if entry ? _attrName then
          acc // {
            "${entry._attrName}" = extraArgs // (removeAttrs entry [ "_attrName" ]) // (pageFn entry);
          }
        else
          acc
      ) { } entries;
    in
    mkPages ({
      inherit list;
      pages = list;
    } // named);

  mkPages =
    { pages, ... }@args:
    let
      extraArgs = removeAttrs args [ "pages" ];
    in
    extraArgs
    // {
      _type = "pages";
      inherit pages;
    };
}
