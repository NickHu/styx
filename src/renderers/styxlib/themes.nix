# themes
lib: { utils }:
with lib;
with utils;
let
  fetchTemplateDir =
    dir:
    let
      f =
        path: dir:
        mapAttrs' (
          k: v:
          let
            nixFile = match "^(.+)\.nix$" k;
          in
          if v == "directory" then
            nameValuePair k (f (path ++ [ dir ]) (dir + "/${k}"))
          else if nixFile != null then
            nameValuePair (elemAt nixFile 0) (dir + "/${k}")
          else
            nameValuePair k null
        ) (readDir dir);
      cleanup = filterAttrsRecursive (n: v: v != null);
    in
    cleanup (f [ dir ] dir);

  findInTheme = theme: f:
    let
      path = theme + "/${f}";
    in
    if pathExists path then path else null;
in
{
  loadData =
    {
      theme,
      lib,
    }:
    let
      confFile = findInTheme theme "conf.nix";
      libFile = findInTheme theme "lib.nix";
      filesDir = findInTheme theme "files";
      templatesDir = findInTheme theme "templates";
      exampleFile = findInTheme theme "example/site.nix";
      arg = { inherit lib; };
      meta = importApply (theme + "/meta.nix") arg;
    in
    {
      meta = {
        name = meta.id;
      }
      // meta;
      inherit (meta) id;
      path = /. + "${toString theme}";
    }
    // optionalAttrs (libFile != null) { lib = importApply libFile arg; }
    // optionalAttrs (confFile != null) { module = importApply confFile arg; }
    // optionalAttrs (exampleFile != null) { exampleSrc = readFile exampleFile; }
    // optionalAttrs (templatesDir != null) {
      templates = mapAttrsRecursive (path: import) (fetchTemplateDir templatesDir);
    }
    // optionalAttrs (filesDir != null) { files = filesDir; };
}
