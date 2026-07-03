env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.highlightjs;
    in
      optionalString cnf.enable
      (templates.tag.link-css {href = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/styles/${cnf.style}.min.css";});
in
  template env
