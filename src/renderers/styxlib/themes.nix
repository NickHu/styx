# themes
lib: styxlib:
with lib;
assert assertMsg (hasAttr "utils" styxlib) "styxlib.themes uses styxlib.utils";
assert assertMsg (hasAttr "proplist" styxlib) "styxlib.themes uses styxlib.proplist";
assert assertMsg (hasAttr "conf" styxlib) "styxlib.themes uses styxlib.conf";
with styxlib.utils;
with styxlib.proplist;
with styxlib.conf;
let
  /*
    Recursively fetches a directory of templates
    return a recursive set of { NAME = FILE }
  */
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
          # non-nix files
          else
            nameValuePair k null
        ) (readDir dir);
      # removing any non-nix files
      cleanup = filterAttrsRecursive (n: v: v != null);
    in
    cleanup (f [ dir ] dir);

  /*
    find a file in a theme
    return null if not found
  */
  findInTheme = t: f: if dirContains t.path f then t.path + "/${f}" else null;
in
{
  loadData =
    {
      theme,
      lib,
    }:
    let
      confFile = findInTheme { path = theme; } "conf.nix";
      libFile = findInTheme { path = theme; } "lib.nix";
      filesDir = findInTheme { path = theme; } "files";
      templatesDir = findInTheme { path = theme; } "templates";
      exampleFile = findInTheme { path = theme; } "example/site.nix";
      arg = { inherit lib; };
      meta = importApply (theme + "/meta.nix") arg;
    in
    {
      # meta information
      meta = {
        name = meta.id;
      }
      // meta;
      # id
      inherit (meta) id;
      # path
      path = /. + "${toString theme}";
    }
    # function library
    // optionalAttrs (libFile != null) { lib = importApply libFile arg; }
    # configuration interface declarations and documentation
    // (optionalAttrs (confFile != null) { decls = importApply confFile arg; })
    // (optionalAttrs (exampleFile != null) { exampleSrc = readFile exampleFile; })
    // (optionalAttrs (templatesDir != null) {
      templates = mapAttrsRecursive (path: import) (fetchTemplateDir templatesDir);
    })
    // (optionalAttrs (filesDir != null) { files = filesDir; });
}
