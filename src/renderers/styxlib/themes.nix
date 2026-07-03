# Theme loading and configuration (nixpkgs lib.evalModules).
lib: nixpkgs: { utils, importApply }:
with lib;
with utils;
let
  siteBaseModule =
    { lib, ... }:
    {
      options.siteUrl = lib.mkOption {
        type = lib.types.str;
        description = "Absolute URL of the deployed site, without a trailing slash.";
        example = "https://example.com";
      };

      options.renderDrafts = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "When false, markdown posts with a `draft` attribute are omitted from listings.";
      };
    };

  moduleArgs = styxlib: {
    inherit styxlib;
    lib = styxlib;
    pkgs = nixpkgs;
  };

  coerceModule =
    config: styxlib:
    let
      args = moduleArgs styxlib;
      raw =
        if isPath config then
          importApply config args
        else if isFunction config then
          config args
        else
          config;
      isModule =
        raw ? options
        || raw ? imports
        || raw ? _file
        || (raw ? config && isAttrs raw.config);
    in
    if isModule then raw else { config = raw; };

  evalConfig =
    {
      styxlib,
      themeModules ? [ ],
      configModules ? [ ],
    }:
    evalModules {
      specialArgs = moduleArgs styxlib;
      modules = [
        siteBaseModule
      ]
      ++ themeModules
      ++ configModules;
    };

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

  mkLoad =
    styxlib:
    {
      lib,
      themes ? [ ],
      config ? [ ],
      env ? { },
    }:
    let
      themesData = map (theme: loadData { inherit theme lib; }) themes;
      themeModules = catAttrs "module" themesData;
      configModules = map (c: coerceModule c lib) config;
      evaluated = evalConfig {
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
in
{
  inherit loadData mkLoad;
}
