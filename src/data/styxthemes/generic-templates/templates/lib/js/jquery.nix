/*
Template to load the jquery javascript library
*/
env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib; let
      cnf = conf.theme.lib.jquery;
    in
      optionalString cnf.enable
      (templates.tag.script {
        src = "//code.jquery.com/jquery-${cnf.version}.min.js";
        crossorigin = "anonymous";
      });
in
  template env
