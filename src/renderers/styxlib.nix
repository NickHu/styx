{
  pkgs,
  parsers,
}:
let
  l = pkgs.lib // builtins;
  markup = import ./styxlib/markup.nix { inherit pkgs parsers; };

  utils = import ./styxlib/utils.nix l;
  build = import ./styxlib/build.nix l pkgs { inherit utils markup; };

  themesCore = import ./styxlib/themes.nix l pkgs { inherit utils; };

  styxlib =
    l
    // {
      inherit utils markup;
      inherit (build) data pages template generation;

      apps = import ./styxlib/apps.nix { inherit pkgs; };
      themes = themesCore;
    };
in
styxlib // {
  themes = themesCore // {
    load = themesCore.mkLoad styxlib;
  };
}
