env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.bootstrap;
    in
      optionalString cnf.enable
      (templates.tag.script {
        src = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/js/bootstrap.min.js";
        crossorigin = "anonymous";
      });
in
  template env