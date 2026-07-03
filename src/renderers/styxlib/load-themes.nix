# themes
lib: nixpkgs: styxlib:
with lib;
# assert assertMsg (hasAttr "utils" styxlib) "styxlib.load-themes uses styxlib.utils";
# assert assertMsg (hasAttr "conf" styxlib) "styxlib.load-themes uses styxlib.conf";
# assert assertMsg (hasAttr "themes" styxlib) "styxlib.load-themes uses styxlib.themes";
with styxlib.utils;
with styxlib.conf;
with styxlib.themes;
{
  mergeConfs =
    confs:
    merge (
      map (
        c:
        if isPath c then
          importApply c {
            pkgs = nixpkgs;
            lib = styxlib; # load entire (second stage) styxlib
          }
        else
          c
      ) confs
    );

  load =
    {
      lib,
      themes ? [ ],
      config ? [ ],
      env ? { },
    }:
    let
      # use secondStageStyxlib to make things like loadFile available
      # in a site's / theme's 'conf.nix' file
      decls = secondStageStyxlib.themes.mergeConfs ([ lib.styxOptions ] ++ config);
      root = parseDecls {
        inherit decls;
        optionFn = o: o.default or null;
      };
      secondStageStyxlib = styxlib.hydrate (_: _: { config = root; });

      themesData = map (theme: loadData { inherit theme lib; }) themes;
      lib' = merge ([ secondStageStyxlib ] ++ (catAttrs "lib" themesData));
      decls' = merge (catAttrs "decls" themesData);
      files = catAttrs "files" themesData;

      conf' =
        let
          theme = parseDecls {
            decls = decls';
            optionFn = o: o.default or null;
          };
          typeCheckResult = if theme != { } then typeCheck decls' theme else null;
          merged = merge [
            { inherit theme; }
            root
          ];
        in
        deepSeq typeCheckResult merged;

      env' = env // {
        # always prefer explicitly specified values
        lib = env.lib or lib';
        conf = env.conf or conf';
        templates = env.templates or templates';
      };

      templates' =
        let
          templatesSet = merge (catAttrs "templates" themesData);
        in
        mapAttrsRecursive (path: template: template env') templatesSet;
    in
    {
      inherit files;
      lib = lib';
      decls = decls';
      env = env';
      conf = conf';
      templates = templates';
      themes = themesData;
    };
}
