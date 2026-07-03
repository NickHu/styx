{
  description = "A styx site";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    styx.url = "github:styx-static/styx";
    styx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    styx,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        styxlib = styx.lib.${system};
        styxthemes = styx.legacyPackages.${system}.styxthemes;

        mkSite = extraConf:
          (import ./site.nix {
            inherit pkgs styxlib styxthemes extraConf;
          })
          .site;

        previewHost = "127.0.0.1";
        previewPort = 8080;
      in {
        packages = {
          # the "real" site, built with the `siteUrl` set in conf.nix
          default = mkSite {};
          # the same site, but with `siteUrl` overridden so relative links
          # resolve correctly when browsing it locally (see `apps.serve`)
          preview = mkSite {siteUrl = "http://${previewHost}:${toString previewPort}";};
        };

        checks.default = self.packages.${system}.default;

        apps = {
          serve = styxlib.apps.mkServe {
            site = self.packages.${system}.preview;
            host = previewHost;
            port = previewPort;
          };
          linkcheck = styxlib.apps.mkLinkcheck {
            site = self.packages.${system}.preview;
            host = previewHost;
            port = previewPort;
          };
          deploy-gh-pages = styxlib.apps.mkGhPagesDeploy {
            site = self.packages.${system}.default;
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [pkgs.caddy pkgs.lychee];
        };

        formatter = pkgs.alejandra;
      }
    );
}
