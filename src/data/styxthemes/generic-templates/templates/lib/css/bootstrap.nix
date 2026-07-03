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
      cnf = conf.theme.lib.bootstrap;
    in
    optionalString cnf.enable (
      templates.tag.link-css {
        href = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/css/bootstrap.min.css";
      }
    );
in
template env
