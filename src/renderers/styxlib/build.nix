# Data loading, pages, templates, and site output (internal helpers in utils).
lib: nixpkgs: { utils, markup, importApply }:
with lib;
with utils;
let
  evaledMarkup = markup;
  evaledMarkupFiles = mapAttrs (n: v: v.extensions) evaledMarkup;
  evaledMarkupExts = flatten (attrValues evaledMarkupFiles);

  supportedFiles = {
    "nix" = [ "nix" ];
  }
  // evaledMarkupFiles;
  supportedExts = flatten (attrValues supportedFiles);

  parseMarkupFile =
    {
      fileData,
      env,
    }:
    let
      markupType = head (attrNames (filterAttrs (k: elem fileData.ext) evaledMarkupFiles));
      markupAttrs = [
        "intro"
        "pages"
        "content"
      ];
      dataFn = nixpkgs.runCommand "parsed-data.nix" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } (evaledMarkup."${markupType}".parser fileData.path);
      data = importApply dataFn env;
    in
    mapAttrs (
      k: v:
      if elem k markupAttrs then
        if k == "pages" then
          map (c: {
            content = markupToHtml markupType c;
            inherit fileData;
          }) v
        else
          markupToHtml markupType v
      else
        v
    ) data;

  parseFile =
    {
      fileData,
      env,
    }:
    let
      m = match "^([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?)?\-?(.*)$" fileData.basename;
      date = if m != null && (elemAt m 0) != null then { date = elemAt m 0; } else { };
      data =
        if elem fileData.ext evaledMarkupExts then
          parseMarkupFile { inherit fileData env; }
        else if fileData.ext == "nix" then
          importApply fileData.path env
        else
          trace "Warning: File '${fileData.path}' is not in a supported file format and will be ignored." { };
    in
    { inherit fileData; } // date // data;

  markupToHtml =
    markupType: text:
    let
      data = nixpkgs.runCommand "markup-data.html" {
        preferLocalBuild = true;
        allowSubstitutes = false;
        inherit text;
        passAsFile = [ "text" ];
      } (evaledMarkup."${markupType}".converter "$textPath");
    in
    readFile data;

  getFileData =
    path:
    let
      m = match "^(.*/)([^/]*)\\.([^.]+)$" (toString path);
      dir = elemAt m 0;
      basename = elemAt m 1;
      ext = elemAt m 2;
    in
    {
      inherit
        dir
        basename
        ext
        path
        ;
      name = "${basename}.${ext}";
    };

  getFiles =
    dir:
    let
      fileList = mapAttrsToList (
        k: v:
        let
          m = match "^(.*)\\.([^.]+)$" k;
          basename = elemAt m 0;
          ext = elemAt m 1;
          path = "${dir}/${k}";
        in
        if (v == "regular") && (m != null) && (elem ext supportedExts) then
          getFileData path
        else
          trace "Warning: File '${path}' is not in a supported file format and will be ignored." null
      ) (readDir dir);
    in
    filter (x: x != null) fileList;
in
rec {
  data = {
    loadDir =
      {
        dir,
        filterDraftsFn ? (
          d: !((!(attrByPath [ "conf" "renderDrafts" ] false env)) && (attrByPath [ "draft" ] false d))
        ),
        asAttrs ? false,
        env ? { },
        ...
      }@args:
      let
        extraArgs = removeAttrs args [
          "dir"
          "filterDraftsFn"
          "asAttrs"
          "env"
        ];
        data = map (fileData: (parseFile { inherit fileData env; }) // extraArgs) (getFiles dir);
        list = filter filterDraftsFn data;
        attrs = foldr (d: acc: acc // { "${d.fileData.basename}" = d; }) { } list;
      in
      if asAttrs then attrs else list;

    loadFile =
      {
        env ? { },
        file,
        ...
      }@args:
      let
        extraArgs = removeAttrs args [
          "file"
          "env"
        ];
      in
      (parseFile {
        fileData = getFileData file;
        inherit env;
      })
      // extraArgs;

    markdownToHtml = markupToHtml "markdown";
    asciidocToHtml = markupToHtml "asciidoc";
  };

  pages = rec {
    mkSplitPagePath =
      {
        index,
        pre,
        post ? ".html",
      }:
      if index == 1 then "${pre}${post}" else "${pre}-${toString index}${post}";

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
        loop =
          index: data: pages:
          let
            index' = index + 1;
            inherit ((pageFn index (head data))) itemsNb;
            items = take itemsNb data;
            page = (removeAttrs (pageFn index data) [ "itemsNb" ]) // {
              inherit index items;
            };
            pages' = pages ++ [ page ];
            data' = drop itemsNb data;
          in
          if data == [ ] then pages else loop index' data' pages';
        pages = loop 1 data [ ];
      in
      map (p: p // { inherit pages; }) pages;

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
  };

  template = rec {
    processBlocks = blocks: {
      content = mapTemplate (b: b.content) blocks;
      extraJS = flatten (catAttrs "extraJS" blocks);
      extraCSS = flatten (catAttrs "extraCSS" blocks);
    };

    htmlAttr =
      attrName: value:
      let
        value' = if isList value then concatStringsSep " " value else value;
      in
      ''${attrName}="${value'}"'';

    htmlAttrs = s: concatStringsSep " " (mapAttrsToList htmlAttr s);

    escapeHTML = replaceStrings [ "<" ">" "\"" "&" ] [ "&lt;" "&gt;" "&quot;" "&amp;" ];

    normalTemplate =
      f: p:
      let
        content = if isFunction f then f p else f;
        contentSet = if isAttrs content then content else { inherit content; };
      in
      p // contentSet;

    mapTemplate = concatMapStringsSep "\n";

    parseDate =
      date:
      let
        year = default (substring 0 4 date) "1970";
        month = default (substring 5 2 date) "01";
        day = default (substring 8 2 date) "01";
        hour = default (substring 11 2 date) "00";
        minut = default (substring 14 2 date) "00";
        second = default (substring 17 2 date) "00";
        default = x: default: if (x == "") then default else x;
        monthConv = {
          "01" = {
            b = "Jan";
            B = "January";
          };
          "02" = {
            b = "Feb";
            B = "February";
          };
          "03" = {
            b = "Mar";
            B = "March";
          };
          "04" = {
            b = "Apr";
            B = "April";
          };
          "05" = {
            b = "May";
            B = "May";
          };
          "06" = {
            b = "Jun";
            B = "June";
          };
          "07" = {
            b = "Jul";
            B = "July";
          };
          "08" = {
            b = "Aug";
            B = "August";
          };
          "09" = {
            b = "Sep";
            B = "September";
          };
          "10" = {
            b = "Oct";
            B = "October";
          };
          "11" = {
            b = "Nov";
            B = "November";
          };
          "12" = {
            b = "Dec";
            B = "December";
          };
        };
        doNotPad =
          x:
          let
            m = builtins.match "^0+([0-9]+)$" x;
          in
          if m != null then elemAt m 0 else x;
      in
      rec {
        date = {
          num = "${YYYY}-${MM}-${DD}";
          lit = "${D} ${B} ${YYYY}";
        };
        time = "${hh}:${mm}:${ss}";
        T = "${date.num}T${time}Z";
        YYYY = year;
        YY = substring 2 4 year;
        Y = YYYY;
        y = YY;
        MM = month;
        M = doNotPad MM;
        m = MM;
        m- = M;
        inherit (monthConv."${MM}") b;
        inherit (monthConv."${MM}") B;
        DD = day;
        D = doNotPad DD;
        d- = D;
        hh = hour;
        h = doNotPad hh;
        mm = minut;
        ss = second;
      };
  };

  generation = rec {
    generatePage = page: page.layout (page.template page);

    mkSite =
      {
        meta ? { },
        files ? [ ],
        pageList ? [ ],
        substitutions ? { },
        preGen ? "",
        postGen ? "",
        genPageFn ? generatePage,
        pagePathFn ? (page: page.path),
      }:
      let
        env = {
          meta = {
            platforms = lib.platforms.all;
          }
          // meta;
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        name = meta.name or "styx-site";
      in
      nixpkgs.runCommand name env ''
        shopt -s globstar
        mkdir -p $out

        text_file () {
          ${nixpkgs.file}/bin/file $1 | grep text | cut -d: -f1
        }

        run_subs () {
          cp $1 subs && chmod u+rw subs
          ${concatMapStringsSep "\n" (
            set:
            let
              key = head (attrNames set);
              value = head (attrValues set);
            in
            ''
              substituteInPlace subs \
                --subst-var-by "${key}" "${toString value}"
            ''
          ) (setToList substitutions)}
        }

        ${preGen}

        ${concatMapStringsSep "\n" (filesDir: ''
          for file in ${filesDir}/**/*; do
            if [ -d "$file" ]; then continue; fi
            path=$(realpath -s --relative-to="${filesDir}" "$file")
            mkdir -p $(dirname $out/$path)
            if [ $(text_file $file) ]; then
              input=$file
              hasSubs=
              run_subs $file
              if [ $(cmp --silent subs $file || echo 1) ]; then
                input=subs
                hasSubs=1
              fi
              if [ "$hasSubs" ]; then
                cp "$input" "$out/$path"
              else
                ln -s "$input" "$out/$path"
              fi
            else
              [ -f "$out/$path" ] && rm "$out/$path"
              ln -s "$file" "$out/$path"
            fi
          done;
        '') files}

        ${concatMapStringsSep "\n" (page: ''
          outPath="$out${pagePathFn page}"
          page=${nixpkgs.writeText "${name}-page" (genPageFn page)}
          mkdir -p "$(dirname "$outPath")"
          run_subs "$page"
          if [ $(cmp --silent subs $page || echo 1) ]; then
            cp "subs" "$outPath"
          else
            ln -s "$page" "$outPath"
          fi
        '') pageList}

        ${postGen}
      '';

    pagesToList =
      {
        pages,
        default ? { },
      }:
      let
        pages' = attrValues pages;
      in
      foldr (
        p: acc:
        if isList p then
          acc ++ (map (recursiveUpdate default) p)
        else if (p ? _type && p._type == "pages") then
          acc ++ (map (recursiveUpdate default) p.pages)
        else
          acc ++ [ (recursiveUpdate default p) ]
      ) [ ] pages';

    # context and returns `{ data, pages, pagesDefault ? {}, mkSiteArgs ? {} }`.
    mkSitePackage =
      {
        styxlib,
        themes,
        config ? [ ],
        body,
        extraEnv ? { },
      }:
      let
        siteBody = body;
      in
      rec {
        loaded = styxlib.themes.load {
          lib = styxlib;
          inherit themes config;
          env = (siteBody loaded) // extraEnv;
        };
        inherit (loaded) conf files templates lib;
        env = loaded.env;
        data = (siteBody loaded).data or { };
        pages = (siteBody loaded).pages;
        pageList = pagesToList {
          inherit pages;
          default = (siteBody loaded).pagesDefault or { };
        };
        site = mkSite ({ inherit files pageList; } // ((siteBody loaded).mkSiteArgs or { }));
      };
  };
}
