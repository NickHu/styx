{
  lib,
  ...
}:
{
  options.theme.lib.bootstrap.enable = lib.mkEnableOption "bootstrap";
  options.theme.lib.bootstrap.version = lib.mkOption {
    type = lib.types.str;
    default = "3.3.7";
    description = "Bootstrap version loaded from bootstrapcdn.com.";
  };

  options.theme.lib.jquery.enable = lib.mkEnableOption "jQuery";
  options.theme.lib.jquery.version = lib.mkOption {
    type = lib.types.str;
    default = "3.1.1";
    description = "jQuery version loaded from code.jquery.com.";
  };

  options.theme.lib.font-awesome.enable = lib.mkEnableOption "font awesome";
  options.theme.lib.font-awesome.version = lib.mkOption {
    type = lib.types.str;
    default = "4.7.0";
    description = "Font Awesome version loaded from bootstrapcdn.com.";
  };

  options.theme.lib.highlightjs.enable = lib.mkEnableOption "highlightjs";
  options.theme.lib.highlightjs.version = lib.mkOption {
    type = lib.types.str;
    default = "9.9.0";
    description = "highlight.js version loaded from cdnjs.";
  };
  options.theme.lib.highlightjs.style = lib.mkOption {
    type = lib.types.str;
    default = "default";
    description = "highlight.js stylesheet; see https://highlightjs.org/static/demo/.";
  };
  options.theme.lib.highlightjs.extraLanguages = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    description = "Extra highlight.js languages; see https://highlightjs.org/static/demo/.";
  };

  options.theme.lib.googlefonts = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    description = "Google Fonts to load; see https://fonts.google.com/.";
  };

  options.theme.lib.mathjax.enable = lib.mkEnableOption "MathJax";

  options.theme.site.title = lib.mkOption {
    type = lib.types.str;
    default = "Generic Templates";
    description = "Default site title used in `<title>` tags.";
  };

  options.theme.html.doctype = lib.mkOption {
    type = lib.types.enum [
      "html5"
      "html4"
      "xhtml1"
    ];
    default = "html5";
    description = "Doctype declaration to use.";
  };

  options.theme.html.lang = lib.mkOption {
    type = lib.types.str;
    default = "en";
    description = "ISO 639-1 language code for the `<html>` tag.";
  };

  options.theme.services.google-analytics.trackingID = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    description = "Google Analytics tracking ID; disabled when null.";
  };

  options.theme.services.piwik.enable = lib.mkEnableOption "Piwik";
  options.theme.services.piwik.url = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Piwik server URL.";
  };
  options.theme.services.piwik.IDsite = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Piwik site id.";
  };

  options.theme.services.disqus.shortname = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
    description = "Disqus shortname; disabled when null.";
  };
}
