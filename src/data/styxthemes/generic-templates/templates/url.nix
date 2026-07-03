env: let
  template = {
    conf,
    lib,
    ...
  }:
    with lib;
      arg:
        if isAttrs arg
        then "${conf.siteUrl}${arg.path}"
        else if (match "^(http|https|ftp|mailto)://.*$" arg) != null
        then arg
        else conf.siteUrl + arg;
in
  template env