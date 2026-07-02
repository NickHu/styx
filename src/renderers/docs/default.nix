{ pkgs, self, styxlib, docslib }: {
  site = siteFn: args: let
    site' = styxlib.callStyxSite siteFn args;
  in
    import ./site.nix {
      inherit pkgs self styxlib docslib;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
  library = siteFn: args: let
    site' = styxlib.callStyxSite siteFn args;
  in
    import ./library.nix {
      inherit pkgs styxlib docslib;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
}
