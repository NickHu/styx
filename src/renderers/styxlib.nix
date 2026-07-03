{
  pkgs,
  parsers,
}:
let
  l = pkgs.lib // builtins;
  importApply = l.modules.importApply;

  markup = import ./styxlib/markup.nix { inherit pkgs parsers; };
  utils = import ./styxlib/utils.nix l;

  build = import ./styxlib/build.nix l pkgs {
    inherit markup utils;
    inherit (utils) callImport;
  };

  themesCore = import ./styxlib/themes.nix l pkgs {
    inherit utils importApply;
  };

  styxlib = l // {
    inherit markup;
    inherit (build.data)
      loadFile
      loadDir
      markdownToHtml
      asciidocToHtml
      ;
    inherit (build.pages)
      mkPageList
      mkSplit
      mkPages
      mkSplitPagePath
      ;
    inherit (build.template)
      processBlocks
      htmlAttr
      htmlAttrs
      escapeHTML
      normalTemplate
      mapTemplate
      parseDate
      ;
    inherit (build.generation)
      generatePage
      mkSite
      pagesToList
      mkSitePackage
      ;
    inherit (utils) find sortBy;

    apps = import ./styxlib/apps.nix { inherit pkgs; };
    themes = themesCore;
  };
in
styxlib
// {
  themes = themesCore // {
    load = themesCore.mkLoad styxlib;
  };
}
