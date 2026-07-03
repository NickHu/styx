{
  pkgs,
  parsers,
}: let
  l = pkgs.lib // builtins;

  styxOptions = import ./styxlib/styx-options.nix {inherit pkgs parsers;};

  res = l.makeExtensibleWithCustomName "_hydrate" (self:
    l // {
    hydrate = f: res._hydrate f;

    config = throw ''
      styxlib.config is only available after loading themes via styxlib.themes.load.
    '';

    inherit styxOptions;

    apps = import ./styxlib/apps.nix {inherit pkgs;};

    data = import ./styxlib/data.nix l pkgs {
      inherit (self) utils proplist config;
    };
    generation = import ./styxlib/generation.nix l pkgs {
      inherit (self) utils;
    };
    pages = import ./styxlib/pages.nix l {
      inherit (self) utils proplist;
    };
    template = import ./styxlib/template.nix l {
      inherit (self) utils;
    };
    themes =
      import ./styxlib/themes.nix l {
        inherit (self) utils proplist conf;
      }
      // (import ./styxlib/load-themes.nix l pkgs self);
    utils = import ./styxlib/utils.nix l;
    proplist = import ./styxlib/proplist.nix l {
      inherit (self) utils;
    };
    conf = import ./styxlib/conf.nix l pkgs {
      inherit (self) utils;
    };
  });
in
  res.hydrate (_: _: {})
