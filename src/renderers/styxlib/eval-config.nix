# Evaluate site/theme configuration with nixpkgs lib.evalModules.
lib: nixpkgs: rec {
  moduleArgs = styxlib: {
    inherit styxlib;
    lib = styxlib;
    pkgs = nixpkgs;
  };

  # Paths, legacy value attrsets, and proper modules are all accepted.
  coerceModule =
    config: styxlib:
    let
      args = moduleArgs styxlib;
      apply = styxlib.utils.importApply;
      raw =
        if lib.isPath config then
          apply config args
        else if lib.isFunction config then
          apply config args
        else
          config;
      isModule =
        raw ? options
        || raw ? imports
        || raw ? _file
        || (raw ? config && lib.isAttrs raw.config);
    in
      if isModule then raw else { config = raw; };

  eval =
    {
      styxlib,
      themeModules ? [ ],
      configModules ? [ ],
    }:
    lib.evalModules {
      specialArgs = moduleArgs styxlib;
      modules = [
        (import ./styx-base-module.nix)
      ]
      ++ themeModules
      ++ configModules;
    };
}
