{
  pkgs,
  styxlib,
  styxthemes ? { },
  extraConf ? { },
}:
styxlib.mkSitePackage {
  inherit styxlib;
  themes = [
    # styxthemes.generic-templates
    # ./themes/my-theme
  ];
  config = [
    ./conf.nix
    extraConf
  ];
  extraEnv = { inherit pkgs; };
  body = loaded: {
    data = { };
    pages = { };
  };
}
