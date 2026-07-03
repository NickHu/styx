{
  pkgs,
  parsers,
}:
let
  l = pkgs.lib // builtins;
  markup = import ./styxlib/markup.nix { inherit pkgs parsers; };

  utils = import ./styxlib/utils.nix l;

  themesCore = import ./styxlib/themes.nix l pkgs { inherit utils; };

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
      template = import ./styxlib/template.nix l;
      themes = themesCore;
    };
in
styxlib // {
  themes = themesCore // {
    load = themesCore.mkLoad styxlib;
  };
}
