{ lib, ... }:
{
  options.theme.site.title = lib.mkOption {
    type = lib.types.str;
    default = "My Site";
    description = "Site title shown in the default layout.";
  };
}
