# Data functions
lib: nixpkgs: { utils, markup }:
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

  # parse markup file to a nix file
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

  # parse a file with the right parser
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

  # Convert markup code to HTML
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

  # extract a file data
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

  # get files from a directory
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
}
