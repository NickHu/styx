# Page functions
lib: styxlib:
with lib;
assert assertMsg (hasAttr "utils" styxlib) "styxlib.pages uses styxlib.utils";
assert assertMsg (hasAttr "proplist" styxlib) "styxlib.pages uses styxlib.proplist";
with styxlib.proplist; rec {
  mkSplitPagePath = {
      index,
      pre,
      post ? ".html",
    }:
      if index == 1
      then "${pre}${post}"
      else "${pre}-${toString index}${post}";

  mkSplitCustom = {
      data,
      pageFn,
    }: let
      loop = index: data: pages: let
        index' = index + 1;
        inherit ((pageFn index (head data))) itemsNb;
        items = take itemsNb data;
        pages' = pages ++ [((removeAttrs (pageFn index data) ["itemsNb"]) // {inherit index items;})];
        data' = drop itemsNb data;
      in
        if data == []
        then pages
        else loop index' data' pages';
      pages = loop 1 data [];
    in
      map (p: p // {inherit pages;}) pages;

  mkSplit = {
      basePath,
      itemsPerPage,
      data,
      ...
    } @ args: let
      extraArgs = removeAttrs args ["basePath" "itemsPerPage" "data"];
      set = {itemsNb = itemsPerPage;};
    in
      mkSplitCustom {
        inherit data;
        pageFn = index: data:
          extraArgs
          // {
            path = mkSplitPagePath {
              inherit index;
              pre = basePath;
            };
            itemsNb = itemsPerPage;
          };
      };

  mkMultipages = {
      pages,
      basePath ? null,
      pageFn ? null,
      ...
    } @ args: let
      extraArgs = removeAttrs args ["basePath" "pageFn" "output" "pages"];
      defPageFn = index: data: (
        optionalAttrs (basePath != null) {
          path = mkSplitPagePath {
            inherit index;
            pre = basePath;
          };
        }
      );
      pageFn' =
        if pageFn == null
        then defPageFn
        else pageFn;
      subpages =
        imap (
          index: page:
            extraArgs
            // (pageFn' index page)
            // (removeAttrs page ["pages"])
        )
        pages;
    in
      imap (index: p:
        p
        // {
          multipages = {
            pages = subpages;
            inherit index;
          };
        })
      subpages;

  mkPageList = {
      data,
      pathPrefix ? "",
      pageFn ? (data: {path = "${pathPrefix}${data.fileData.basename}.html";}),
      multipageFn ? (index: data: {
        path = mkSplitPagePath {
          pre = "${pathPrefix}${data.fileData.basename}";
          inherit index;
        };
      }),
      ...
    } @ args: let
      extraArgs = removeAttrs args ["data" "pathPrefix" "multipageFn" "pageFn"];
      base = {
        list = [];
        extra = [];
        _id = 0;
      };
      fn = d: acc: let
        mpages = map (p: p // {_plid = acc._id;}) (mkMultipages (extraArgs // d // {pageFn = multipageFn;}));
        page = extraArgs // d // (pageFn d);
        list =
          if d ? pages
          then [(head mpages)]
          else [page];
        extra = optionals (d ? pages) (tail mpages);
      in
        acc
        // {
          list = list ++ acc.list;
          extra = extra ++ acc.extra;
          _id = acc._id + 1;
        }
        // (optionalAttrs (d ? _attrName) {"${d._attrName}" = head list;});
      raw = foldr fn base data';
      data' =
        if isAttrs data
        then mapAttrsToList (n: v: v // {_attrName = n;}) data
        else data;
      cleanlist = map (p: removeAttrs p ["_plid"]);
      dirtylist = imap (index: p:
        p
        // {
          pageList = {
            pages = cleanlist raw.list;
            inherit index;
          };
        })
      raw.list;
      list = cleanlist dirtylist;
      extra = cleanlist (map (p: p // {inherit ((findFirst (x: x ? _plid && x._plid == p._plid) "" dirtylist)) pageList;}) raw.extra);
    in
      mkPages ({
          inherit list;
          pages = list ++ extra;
        }
        // (removeAttrs raw ["list" "extra" "_id"]));

  mkPages = {pages, ...} @ args: let
      extraArgs = removeAttrs args ["pages"];
    in
      extraArgs
      // {
        _type = "pages";
        inherit pages;
      };

  mkTaxonomyPages = {
      data,
      taxonomyTemplate ? null,
      termTemplate ? null,
      taxonomyPageFn ? (taxonomy: {}),
      termPageFn ? (taxonomy: term: {}),
      ...
    } @ args: let
      extraArgs = removeAttrs args ["data" "taxonomyTemplate" "termTemplate" "taxonomyPageFn" "termPageFn"];
      taxonomyPages =
        propMap (
          taxonomy: terms:
            extraArgs
            // (optionalAttrs (taxonomyTemplate != null) {template = taxonomyTemplate;})
            // {path = mkTaxonomyPath taxonomy;}
            // {
              inherit terms taxonomy;
              taxonomyData = {"${taxonomy}" = terms;};
            }
            // (taxonomyPageFn taxonomy)
        )
        data;
      termPages = flatten (propMap (
          taxonomy:
            propMap (
              term: values:
                extraArgs
                // (optionalAttrs (termTemplate != null) {template = termTemplate;})
                // {path = mkTaxonomyTermPath taxonomy term;}
                // {inherit taxonomy term values;}
                // (termPageFn taxonomy term)
            )
        )
        data);
    in
      termPages ++ taxonomyPages;

  mkTaxonomyPath = taxonomy: "/${taxonomy}/index.html";

  mkTaxonomyTermPath = taxonomy: term: "/${taxonomy}/${term}/index.html";
}
