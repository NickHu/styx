{
  pkgs,
  styxlib,
  styxthemes,
  libtests,
}: let
  l = pkgs.lib // builtins;

  # every bundled theme's example site, built with a local/relative siteUrl
  # so it can be inspected directly out of the store.
  themes-sites =
    l.mapAttrs' (
      n: v:
        l.nameValuePair "${n}-site"
        (import (v + /example/site.nix) {
          inherit pkgs styxlib styxthemes;
          sampleData = ../data/presets/sample-data/data/sample;
          extraConf = {
            siteUrl = ".";
            renderDrafts = true;
          };
        })
        .site
    )
    (l.filterAttrs (n: _: n != "__functor") styxthemes);

  # A copy of the "new site" template (what `nix flake new/init -t
  # <styx>#default` gives you) with a theme enabled and a page added, so
  # building it actually exercises page rendering rather than producing an
  # empty site.
  patchedNewSiteTemplate =
    pkgs.runCommand "new-site-template-patched" {}
    ''
      cp -r ${../data/presets/new-site} $out
      chmod -R u+w $out
      substituteInPlace $out/site.nix \
        --replace-fail 'themes = [' 'themes = [ styxthemes.generic-templates' \
        --replace-fail 'pages = rec {' 'pages = rec { index = { path = "/index.html"; title = "Hello world!"; content = "<p>Hello world!</p>"; template = templates.page.full; layout = templates.layout; };'
    '';

  new-site =
    (import (patchedNewSiteTemplate + /site.nix) {
      inherit pkgs styxlib styxthemes;
    })
    .site;

  # A minimal site using only the "new theme" template (what `nix flake new
  # -t <styx>#theme DIR` gives you), checking that the scaffolded theme
  # actually renders a page.
  new-theme = let
    loaded = styxlib.themes.load {
      lib = styxlib;
      themes = [../data/presets/new-theme];
      config = [{theme.site.title = "New Theme Test";}];
      env = {
        data = {};
        pages = {};
      };
    };
    page = {
      title = "Hello";
      content = "<p>Hi</p>";
      template = loaded.templates.page.full;
      layout = loaded.templates.layout;
    };
    rendered = page.layout (page.template page);
  in
    pkgs.runCommand "check-new-theme" {} ''
      cat > out.html <<'PAGE'
      ${rendered}
      PAGE
      grep -qF 'New Theme Test' out.html
      grep -qF '<h1>Hello</h1>' out.html
      grep -qF '<p>Hi</p>' out.html
      touch $out
    '';

  # `styxlib.apps.mkGhPagesDeploy`, exercised against a scratch git repo:
  # deploying twice must be idempotent.
  deploy-gh-pages = let
    testSite =
      pkgs.runCommand "deploy-gh-pages-test-site" {}
      ''
        mkdir -p $out
        echo hello > $out/index.html
      '';
    deployApp = styxlib.apps.mkGhPagesDeploy {site = testSite;};
  in
    pkgs.runCommand "check-deploy-gh-pages" {
      nativeBuildInputs = [pkgs.git];
    } ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export GIT_CONFIG_NOSYSTEM=1
      mkdir -p "$HOME"
      git config --global user.name "styx test"
      git config --global user.email "styx@test.styx"
      git config --global init.defaultBranch main
      # never GPG-sign in tests, regardless of any inherited config
      git config --global commit.gpgsign false
      git config --global tag.gpgsign false

      mkdir repo && cd repo
      git init -q
      echo "site.nix" >site.nix
      git add . && git commit -q -m "init repo"

      ${deployApp.program}
      git show-ref --quiet --verify refs/heads/gh-pages
      grep -qF hello gh-pages/index.html

      # re-running must be idempotent (update in place, not fail/duplicate)
      ${deployApp.program}
      git show-ref --quiet --verify refs/heads/gh-pages

      touch $out
    '';
in
  {
    inherit new-site new-theme deploy-gh-pages;
  }
  // themes-sites
  // {
    lib-report = let
      lsep = "====================\n";
      sep = "---\n";
      inSep = x: sep + x + sep;
      pretty = l.generators.toPretty {};
      hasFailures = (l.length libtests.results.failures) > 0;
      report = ''
        ---
        Lib Tests Report
        ${l.toString ((l.length libtests.results.success) + (l.length libtests.results.failures))} tests run.
        - ${l.toString (l.length libtests.results.success)} success(es).
        - ${l.toString (l.length libtests.results.failures)} failure(s).
        ${l.optionalString hasFailures ''

          Failures details:

          ${lsep}${styxlib.template.mapTemplate (
              failure: let
                header = "${failure.name}${l.optionalString (failure ? index) ", example number ${l.toString failure.index}"}:\n";
                code = l.optionalString (failure ? literalCode) ("\ncode:\n" + inSep failure.literalCode);
                expected = "\nexpected:\n" + inSep "${pretty failure.expected}\n";
                got = "\ngot:\n" + inSep "${pretty failure.code}\n";
              in
                header + code + expected + got + lsep
            )
            libtests.results.failures}''}
        ---
      '';
      reportFile = pkgs.writeText "lib-tests-report.txt" report;
    in
      pkgs.runCommand "lib-tests-report" {}
      (''
          cp ${reportFile} $out
          cat $out
        ''
        + l.optionalString hasFailures ''
          echo "error: ${toString (l.length libtests.results.failures)} lib test failure(s), see report above" >&2
          exit 1
        '');

    # informational only: a growing number of undocumented/untested library
    # functions is not (by itself) a build failure.
    lib-coverage = pkgs.writeText "lib-tests-coverage.txt" ''
      ---
      Lib Tests Coverage
      ${l.toString (l.length libtests.missingTests)} functions missing tests:

      ${styxlib.template.mapTemplate (f: " - ${f}") libtests.missingTests}
      ---
    '';
  }
