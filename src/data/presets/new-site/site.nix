/*
    -----------------------------------------------------------------------------
     Init

     Initialization of Styx, should not be edited
  -----------------------------------------------------------------------------
*/
{
  pkgs,
  styxlib,
  styxthemes ? { },
  extraConf ? { },
}:
rec {
  /*
      -----------------------------------------------------------------------------
       Setup

       This section sets up the configuration and the themes used by the site.
    -----------------------------------------------------------------------------
  */

  loaded = styxlib.themes.load {
    lib = styxlib;

    # Used configuration
    config = [
      ./conf.nix
      extraConf
    ];

    # Loaded themes
    themes = [
      # Declare the used themes here, from styx's bundled theme set:
      #   styxthemes.generic-templates
      # or from a local path:
      #   ./themes/my-theme
    ];

    # Environment propagated to templates
    env = { inherit data pages pkgs; };
  };

  # Propagating initialized data
  inherit (loaded)
    conf
    files
    templates
    env
    lib
    ;

  /*
      -----------------------------------------------------------------------------
       Data

       This section declares the data used by the site
    -----------------------------------------------------------------------------
  */

  data = {
  };

  /*
      -----------------------------------------------------------------------------
       Pages

       This section declares the pages that will be generated
    -----------------------------------------------------------------------------
  */

  pages = rec {
  };

  /*
      -----------------------------------------------------------------------------
       Site

    -----------------------------------------------------------------------------
  */

  # Converting the pages attribute set to a list
  pageList = lib.generation.pagesToList { inherit pages; };

  # Generating the site
  site = lib.generation.mkSite { inherit files pageList; };
}
