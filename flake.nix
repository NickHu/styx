{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      utils,
      nixpkgs,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        l = pkgs.lib // builtins;

        parsers = import ./src/app/parsers.nix { inherit pkgs; };
        styxthemes = import ./src/data/styxthemes.nix { inherit pkgs; };
        styxlib = import ./src/renderers/styxlib.nix { inherit pkgs parsers; };

        version = l.unsafeDiscardStringContext (l.fileContents (self + /VERSION));
        docsSrc = self + /docs;

        docsPackage = pkgs.stdenv.mkDerivation {
          pname = "styx-docs";
          inherit version;

          preferLocalBuild = true;
          allowSubstitutes = false;

          nativeBuildInputs = [ pkgs.asciidoctor ];

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out
            asciidoctor ${docsSrc}/index.adoc -o $out/index.html
            substituteInPlace $out/index.html --replace-fail '@version@' '${version}'
            asciidoctor ${docsSrc}/styx-themes.adoc -o $out/styx-themes.html
            substituteInPlace $out/styx-themes.html --replace-fail '@version@' '${version}'
            asciidoctor ${docsSrc}/library.adoc -o $out/library.html
            substituteInPlace $out/library.html --replace-fail '@version@' '${version}'
            cp -r ${docsSrc}/highlight $out/
            if [ -d ${docsSrc}/imgs ]; then
              cp -r ${docsSrc}/imgs $out/
            fi
          '';
        };

        themes-sites = l.mapAttrs' (
          n: v:
          l.nameValuePair "${n}-site"
            (import (v + /example/site.nix) {
              inherit pkgs styxlib styxthemes;
              sampleData = ./src/data/presets/sample-data/data/sample;
              extraConf = {
                siteUrl = ".";
                renderDrafts = true;
              };
            }).site
        ) (l.filterAttrs (n: _: n != "__functor") styxthemes);

        patchedNewSiteTemplate = pkgs.runCommand "new-site-template-patched" { } ''
          cp -r ${./src/data/presets/new-site} $out
          chmod -R u+w $out
          substituteInPlace $out/site.nix \
            --replace-fail 'themes = [' 'themes = [ styxthemes.generic-templates' \
            --replace-fail 'pages = rec {' 'pages = rec { index = { path = "/index.html"; title = "Hello world!"; content = "<p>Hello world!</p>"; template = templates.page.full; layout = templates.layout; };'
        '';

        new-site =
          (import (patchedNewSiteTemplate + /site.nix) {
            inherit pkgs styxlib styxthemes;
          }).site;

        new-theme =
          let
            loaded = styxlib.themes.load {
              lib = styxlib;
              themes = [ ./src/data/presets/new-theme ];
              config = [ { theme.site.title = "New Theme Test"; } ];
              env = {
                data = { };
                pages = { };
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
          pkgs.runCommand "check-new-theme" { } ''
            cat > out.html <<'PAGE'
            ${rendered}
            PAGE
            grep -qF 'New Theme Test' out.html
            grep -qF '<h1>Hello</h1>' out.html
            grep -qF '<p>Hi</p>' out.html
            touch $out
          '';

        deploy-gh-pages =
          let
            testSite = pkgs.runCommand "deploy-gh-pages-test-site" { } ''
              mkdir -p $out
              echo hello > $out/index.html
            '';
            deployApp = styxlib.apps.mkGhPagesDeploy { site = testSite; };
          in
          pkgs.runCommand "check-deploy-gh-pages"
            {
              nativeBuildInputs = [ pkgs.git ];
            }
            ''
              export HOME="$TMPDIR/home"
              export XDG_CONFIG_HOME="$HOME/.config"
              export GIT_CONFIG_NOSYSTEM=1
              mkdir -p "$HOME"
              git config --global user.name "styx test"
              git config --global user.email "styx@test.styx"
              git config --global commit.gpgsign false
              git config --global tag.gpgsign false

              mkdir repo && cd repo
              git init -q
              echo "site.nix" >site.nix
              git add . && git commit -q -m "init repo"

              ${deployApp.program}
              git show-ref --quiet --verify refs/heads/gh-pages
              grep -qF hello gh-pages/index.html

              ${deployApp.program}
              git show-ref --quiet --verify refs/heads/gh-pages

              touch $out
            '';

        checks = {
          inherit new-site new-theme deploy-gh-pages;
        }
        // themes-sites;
      in
      {
        packages = {
          docs = docsPackage;
          default = docsPackage;
        };

        lib = styxlib;
        legacyPackages = { inherit styxthemes; };
        devShells.default = pkgs.mkShell {
          name = "styx";
          packages = with pkgs; [
            pandoc
            asciidoctor
            statix
          ];
        };
        formatter = pkgs.nixfmt;

        apps = {
          doc = utils.lib.mkApp {
            drv = pkgs.writeShellApplication {
              name = "styx-doc";
              runtimeInputs = [ pkgs.xdg-utils ];
              text = ''
                exec xdg-open "${docsPackage}/index.html"
              '';
            };
          };
        };

        inherit checks;
      }
    )
    // {
      templates = import ./src/data/presets.nix;
    };
}
