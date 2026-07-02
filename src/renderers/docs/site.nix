{ pkgs, self, styxlib, docslib, site }: let
  l = pkgs.lib // builtins;

  highlightSrc = self + /docs/highlight;
  themes = l.reverseList site.loaded.themes;
  pages =
    if site ? pages
    then styxlib.generation.pagesToList {inherit (site) pages;}
    else [];
  doc = pkgs.writeText "site.adoc" ''

    ////

    File automatically generated, do not edit

    ////

    = ${site.name or "Styx Site"} Documentation
    :description: Site documentation
    :toc: left
    :toclevels: 3
    :icons: font
    :sectanchors:
    :nofooter:
    :experimental:
    :source-highlighter: highlightjs
    :highlightjsdir: highlight

    :sectnums:

    ${
      if pages != []
      then docslib.pagesDoc pages
      else ""
    }

    ${
      if themes != []
      then docslib.themesDoc site.loaded.env themes
      else ""
    }

  '';
in
  pkgs.stdenv.mkDerivation rec {
    name = "styx-docs";
    unpackPhase = ":";

    preferLocalBuild = true;
    allowSubstitutes = false;

    buildInputs = [pkgs.asciidoctor];

    buildPhase = ''
      mkdir build
      asciidoctor ${doc} -o build/index.html
    '';

    installPhase = ''
      mkdir $out
      ${styxlib.template.mapTemplate (
          t:
            l.optionalString (t.meta ? screenshot) ''
              mkdir -p $(dirname "$out/${docslib.mkScreenshotPath t}")
              cp ${t.meta.screenshot} "$out/${docslib.mkScreenshotPath t}"
            ''
        )
        themes}
      cp build/index.html $out/
      cp -r ${highlightSrc} $out/
      cp ${pkgs.writeText "themes.adoc" (docslib.themesDoc site.loaded.env themes)} $out/themes-generated.adoc
    '';
  }
