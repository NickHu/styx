env:
let
  template =
    {
      conf,
      lib,
      templates,
      ...
    }:
    with lib;
    let
      cnf = conf.theme.lib.highlightjs;
    in
    optionalString cnf.enable (
      (templates.tag.script {
        src = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/highlight.min.js";
        crossorigin = "anonymous";
      })
      + (lib.mapTemplate (
        lang:
        (templates.tag.script {
          src = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/languages/${lang}.min.js";
          crossorigin = "anonymous";
        })
      ) cnf.extraLanguages)
      + "<script>hljs.initHighlightingOnLoad();</script>\n"
    );
in
template env
