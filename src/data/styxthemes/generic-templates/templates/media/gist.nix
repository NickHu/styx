env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    {
      user,
      id,
      file ? null,
    }:
    with lib;
    templates.tag.script {
      src = "https://gist.github.com/${user}/${id}.js${optionalString (file != null) "?file=${file}"}";
    };
in
template env
