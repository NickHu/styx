# Theme loading and configuration (nixpkgs lib.evalModules).
lib: nixpkgs: styxlib:
with lib;
with styxlib.utils;
with styxlib.themes;
let
  evalConfig = import ./eval-config.nix lib nixpkgs;
in
{
  load =
    {
      lib,
      themes ? [ ],
      config ? [ ],
      env ? { },
    }:
    let
      themesData = map (theme: loadData { inherit theme lib; }) themes;
      themeModules = catAttrs "module" themesData;
      configModules = map (c: evalConfig.coerceModule c lib) config;
      evaluated = evalConfig.eval {
        inherit styxlib themeModules configModules;
      };
      conf' = evaluated.config;
      lib' = foldl' recursiveUpdate lib (catAttrs "lib" themesData);
      files = catAttrs "files" themesData;

      env' = env // {
        lib = env.lib or lib';
        conf = env.conf or conf';
        templates = env.templates or templates';
      };

      templates' =
        let
          templatesSet = foldl' recursiveUpdate { } (catAttrs "templates" themesData);
        in
        mapAttrsRecursive (path: template: template env') templatesSet;
    in
    {
      inherit files;
      lib = lib';
      env = env';
      conf = conf';
      templates = templates';
      themes = themesData;
    };
}
