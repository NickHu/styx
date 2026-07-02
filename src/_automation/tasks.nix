# NOTE: run-tests/update-doc shell out to `nix run/build .#_automation.tests.X`,
# which assumes the ./src/_automation/tests.nix outputs are wired into your
# flake.nix under that attrpath. They aren't in this repo's flake.nix by
# default (see flake.nix comments) -- wire them up if you want this script
# usable as-is.
{ pkgs, self, docs, styxlib, styxthemes, styx }: let
  nixpkgs = pkgs;
  l = pkgs.lib // builtins;
in {
  run-tests = let
    run-main = test: ''
      echo "Run '${test}' ..."
      if nix run "${self + "#_automation.tests.${test}"}" --show-trace; then
        echo "  success: ${test}"
      else
        echo "  failure: ${test}"
        exit 1
      fi
    '';
    run-site = test: ''
      echo "Run '${test}' ..."
      if nix build "${self + "#_automation.tests.${test}"}" --show-trace; then
        echo "  success: ${test}"
      else
        echo "  failure: ${test}"
        exit 1
      fi
    '';
    write-report = report: ''
      nix build "${self + "#_automation.tests.${report}"}" --show-trace
      . ./result
    '';
  in
    nixpkgs.writeShellScriptBin "run-tests" ''
      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "Code Linting:"
      echo ""

      ${l.getExe nixpkgs.statix} check

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "Main tests:"
      echo ""

      ${run-main "new"}
      ${run-main "new-build"}
      ${run-main "new-theme"}
      ${run-main "deploy-gh-pages"}

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "Theme tests:"
      echo ""

      ${run-site "generic-templates-site"}
      ${run-site "agency-site"}
      ${run-site "ghostwriter-site"}
      ${run-site "hyde-site"}
      ${run-site "nix-site"}
      ${run-site "orbit-site"}
      ${run-site "showcase-site"}

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "Library tests:"
      echo ""

      ${write-report "lib-report"}
      ${write-report "lib-coverage"}

      echo ""
      echo "Finished"
    '';
  update-doc = let
    site = _: rec {
      loaded =
        (import self {
          pkgs = nixpkgs;
          themes = l.reverseList (l.attrValues styxthemes);
          env = {
            data = {};
            pages = {};
          };
          config = [{siteUrl = "http://domain.org";}];
        })
        .themes;
      site = styxlib.generation.mkSite {
        pageList = styxlib.generation.pagesToList {inherit (loaded.env) pages;};
      };
    };
    doc-site = docs.site site {};
    doc-library = docs.library site {};
  in
    nixpkgs.writeShellScriptBin "update-doc" ''
      repoRoot="$(git rev-parse --show-toplevel)"
      target="$(readlink -f -- "$repoRoot/docs/")"

      if ! cmp "${doc-site}/themes-generated.adoc" "$target/styx-themes-generated.adoc"
      then
        cp ${doc-site}/themes-generated.adoc $target/styx-themes-generated.adoc --no-preserve=all
        cp ${doc-site}/imgs/* $target/imgs/ --no-preserve=all
        echo "Themes documentation updated!"
      fi

      if ! cmp "${doc-library}/library-generated.adoc" "$target/library-generated.adoc"
      then
        cp ${doc-library}/library-generated.adoc $target/library-generated.adoc --no-preserve=all
        echo "Library documentation updated!"
      fi

    '';
}
