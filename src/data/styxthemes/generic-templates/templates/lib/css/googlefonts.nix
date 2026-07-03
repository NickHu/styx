env: let
  template = {
    lib,
    conf,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.googlefonts;
      fonts = concatStringsSep "|" (map (replaceStrings [" "] ["+"]) cnf);
    in
      optionalString (cnf != [])
      (templates.tag.link-css {href = "//fonts.googleapis.com/css?family=${fonts}";});
in
  template env
