{
  pkgs,
  styxlib,
  styxthemes ? { },
  sampleData ? null,
  extraConf ? { },
}:
styxlib.mkSitePackage {
  inherit styxlib;
  themes = [ ../. ];
  config = [
    ./conf.nix
    extraConf
  ];
  body = loaded: rec {
    data = {
      navbar = with pages; [
        theme
        basic
        starter
      ];
    };

    pages = {
      basic = {
        inherit (loaded.templates) layout;
        template = loaded.templates.examples.basic;
        path = "/basic.html";
        title = "Bootstrap 101 Template";
        navbarTitle = "Basic";
      };

      starter = {
        inherit (loaded.templates) layout;
        template = loaded.templates.examples.starter;
        path = "/starter.html";
        title = "Starter Template for Bootstrap";
        navbarTitle = "Starter";
      };

      theme = {
        inherit (loaded.templates) layout;
        template = loaded.templates.examples.theme;
        path = "/index.html";
        title = "Theme Template for Bootstrap";
        navbarTitle = "Theme";
      };
    };
  };
}
