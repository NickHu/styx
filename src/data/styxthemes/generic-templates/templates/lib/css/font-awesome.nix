env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.font-awesome;
    in
      optionalString cnf.enable
      (templates.tag.link-css {href = "//maxcdn.bootstrapcdn.com/font-awesome/${cnf.version}/css/font-awesome.min.css";});
in
  template env
