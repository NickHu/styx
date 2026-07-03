{
  pkgs,
  parsers,
}:
let
  l = pkgs.lib // builtins;
  markup = import ./styxlib/markup.nix { inherit pkgs parsers; };

  utils = import ./styxlib/utils.nix l;

  styxlib =
    l
    // {
      inherit utils markup;

      apps = import ./styxlib/apps.nix { inherit pkgs; };

      data = import ./styxlib/data.nix l pkgs {
        inherit markup utils;
      };
      generation = import ./styxlib/generation.nix l pkgs { inherit utils; };
      pages = import ./styxlib/pages.nix l { inherit utils; };
      template = import ./styxlib/template.nix l { inherit utils; };
      themes = import ./styxlib/themes.nix l { inherit utils; };
    };

  themesWithLoad = styxlib.themes // (import ./styxlib/load-themes.nix l pkgs styxlib);
in
styxlib // { themes = themesWithLoad; }
