/*
  -----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------
*/
{
  pkgs,
  styxlib,
  styxthemes,
  sampleData ? null,
  extraConf ? {},
}: rec {
  /*
    -----------------------------------------------------------------------------
     Setup

     This section setup required variables
  -----------------------------------------------------------------------------
  */

  loaded = styxlib.themes.load {
    lib = styxlib;

    # Used configuration
    config = [./conf.nix extraConf];

    # Loaded themes
    themes = [
      styxthemes.generic-templates
      ../.
    ];

    # Environment propagated to templates
    env = {inherit data pages;};
  };

  # Propagating initialized data
  inherit (loaded) conf files templates env lib;

  /*
    -----------------------------------------------------------------------------
     Data

     This section declares the data used by the site
  -----------------------------------------------------------------------------
  */

  data = with lib.data;
  with lib.lib;
    {
      /*
      Menu using blocks
      */
      menu = let
        mkBlockSet = blocks:
          map (
            id:
              (lib.utils.find {inherit id;} blocks)
              // {
                navbarClass = "page-scroll";
                url = "/#${id}";
              }
          );
      in
        (mkBlockSet pages.index.blocks ["services" "portfolio" "about" "team" "contact"])
        ++ [
          {
            title = "Styx";
            url = "https://styx-static.github.io/styx-site/";
          }
        ];
    }
    // (loadDir {
      dir = ./data;
      inherit env;
      asAttrs = true;
    });

  /*
    -----------------------------------------------------------------------------
     Pages

     This section declares the pages that will be generated
  -----------------------------------------------------------------------------
  */

  pages = with lib.pages;
  with lib.lib; rec {
    index = {
      title = "Home";
      path = "/index.html";
      template = templates.block-page.full;
      inherit (templates) layout;
      blocks = let
        darken = d: d // {class = "bg-light-gray";};
      in
        with templates.blocks; [
          (banner data.main-banner)
          (services data.services)
          (portfolio (darken data.portfolio))
          (timeline data.about)
          (team (darken data.team))
          (clients data.clients)
          (contact data.contact)
        ];
    };
  };

  /*
    -----------------------------------------------------------------------------
     Site rendering

  -----------------------------------------------------------------------------
  */

  # converting pages attribute set to a list
  pageList = lib.generation.pagesToList {
    inherit pages;
    default = {inherit (templates) layout;};
  };

  site = lib.generation.mkSite {inherit files pageList;};
}
