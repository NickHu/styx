env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.mathjax;
    in
      optionalString cnf.enable
      (templates.tag.script {
        src = "//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML";
        crossorigin = "anonymous";
      });
in
  template env