{
  pkgs,
  self,
  styxlib,
  docslib,
  styxthemes ? {},
}: let
  l = pkgs.lib // builtins;

  # Call a site.nix-shaped function (or the internal helpers `update-doc`
  # uses), supplying the standard set of arguments a site's own flake would.
  call = siteFn: args:
    (
      if l.isFunction siteFn
      then siteFn
      else import siteFn
    )
    ({inherit pkgs styxlib styxthemes;} // args);
in {
  site = siteFn: args: let
    site' = call siteFn args;
  in
    import ./site.nix {
      inherit pkgs self styxlib docslib;
      site = site';
    };
  library = siteFn: args: let
    site' = call siteFn args;
  in
    import ./library.nix {
      inherit pkgs styxlib docslib;
      site = site';
    };
}
