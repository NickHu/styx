{ lib, ... }:
{
  config.siteUrl = lib.mkDefault "https://styx-static.github.io/styx-theme-generic-templates";
  config.theme.lib.bootstrap.enable = true;
  config.theme.lib.jquery.enable = true;
  config.theme.lib.font-awesome.enable = true;
}
