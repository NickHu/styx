{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {self, utils, nixpkgs, ...}:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        parsers = import ./src/app/parsers.nix {inherit pkgs;};
        styxthemes = import ./src/data/styxthemes.nix {inherit pkgs;};
        styxlib = import ./src/renderers/styxlib.nix {inherit pkgs parsers;};
        docslib = import ./src/renderers/docslib.nix {inherit pkgs styxlib;};
        docs = import ./src/renderers/docs/default.nix {
          inherit pkgs self styxlib docslib styxthemes;
        };

        libtests = import ./src/_automation/libtests.nix {inherit pkgs styxlib;};
        tests = import ./src/_automation/tests.nix {
          inherit pkgs styxlib styxthemes libtests;
        };
        tasks = import ./src/_automation/tasks.nix {
          inherit pkgs self docs styxlib styxthemes;
        };
        docsPackage = import ./src/_automation/docs-package.nix {inherit pkgs self;};
        devShell = import ./src/_automation/devshells.nix {inherit pkgs;};
      in {
        packages = {
          docs = docsPackage;
          default = docsPackage;
        };

        lib = styxlib;
        legacyPackages = {inherit styxthemes;};
        devShells.default = devShell;
        formatter = pkgs.alejandra;

        apps = {
          doc = utils.lib.mkApp {
            drv = pkgs.writeShellApplication {
              name = "styx-doc";
              runtimeInputs = [pkgs.xdg-utils];
              text = ''
                exec xdg-open "${docsPackage}/index.html"
              '';
            };
          };
          update-doc = utils.lib.mkApp {drv = tasks.update-doc;};
        };

        checks = tests;
      }
    )
    // {
      templates = import ./src/data/presets.nix;
    };
}
