# Site-wide options merged into every styx site build.
{ lib, ... }:
{
  options.siteUrl = lib.mkOption {
    type = lib.types.str;
    description = "Absolute URL of the deployed site, without a trailing slash.";
    example = "https://example.com";
  };

  options.renderDrafts = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "When false, markdown posts with a `draft` attribute are omitted from listings.";
  };
}
