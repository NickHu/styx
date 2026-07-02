# a plain value, not a function: these are `nix flake init -t` templates
# and don't need pkgs/self/anything else
{
  default = {
    description = "Minimal New Styx Site";
    path = ./presets/new-site;
  };
  sample-data = {
    description = "Sample pages & posts";
    path = ./presets/sample-data;
  };
}
