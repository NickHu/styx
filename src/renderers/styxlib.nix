{
  pkgs,
  parsers,
}:
let
  l = pkgs.lib // builtins;
  markup = import ./styxlib/markup.nix { inherit pkgs parsers; };

  utils = import ./styxlib/utils.nix l;
  proplist = import ./styxlib/proplist.nix l { inherit utils; };

  styxlib =
    l
    // {
      inherit utils proplist markup;

      apps = import ./styxlib/apps.nix { inherit pkgs; };

      data = import ./styxlib/data.nix l pkgs {
        inherit markup utils proplist;
      };
      generation = import ./styxlib/generation.nix l pkgs { inherit utils; };
      pages = import ./styxlib/pages.nix l { inherit utils proplist; };
      template = import ./styxlib/template.nix l { inherit utils; };
      themes = import ./styxlib/themes.nix l;
    };

  themesWithLoad = styxlib.themes // (import ./styxlib/load-themes.nix l pkgs styxlib);
in
styxlib // { themes = themesWithLoad; }
