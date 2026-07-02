{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, utils, nixpkgs, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # -- src/app -----------------------------------------------------
        styx = import ./src/app/cli.nix { inherit pkgs self; };
        parsers = import ./src/app/parsers.nix { inherit pkgs; };

        # -- src/data ------------------------------------------------------
        styxthemes = import ./src/data/styxthemes.nix { inherit pkgs; };

        # -- src/renderers ---------------------------------------------------
        styxlib = import ./src/renderers/styxlib.nix { inherit pkgs styx parsers; };
        docslib = import ./src/renderers/docslib.nix { inherit pkgs styxlib; };
        docs = import ./src/renderers/docs/default.nix { inherit pkgs self styxlib docslib; };

        # -- src/_automation -------------------------------------------------
        libtests = import ./src/_automation/libtests.nix { inherit pkgs styxlib; };
        tests = import ./src/_automation/tests.nix {
          inherit pkgs styxlib styxthemes styx libtests;
        };
        tasks = import ./src/_automation/tasks.nix {
          inherit pkgs self docs styxlib styxthemes styx;
        };
        devShell = import ./src/_automation/devshells.nix { inherit pkgs; };
      in
      {
        packages = {
          inherit styx;
          default = styx;
          _automation = {
            inherit tests;
          };
        };
        lib = styxlib;
        legacyPackages = { inherit styxthemes; };
        devShells.default = devShell;
        formatter = pkgs.alejandra;

        apps = {
          default = utils.lib.mkApp { drv = tasks.run-tests; };
          run-tests = utils.lib.mkApp { drv = tasks.run-tests; };
          update-doc = utils.lib.mkApp { drv = tasks.update-doc; };
        };

        # `nix flake check`: exercises the library test battery plus a full
        # site build for every vendored theme (mirrors upstream's test task)
        checks =
          pkgs.lib.filterAttrs (n: _: n == "lib-report" || n == "lib-coverage" || pkgs.lib.hasSuffix "-site" n)
            tests;
      }
    ) // {
        templates = import ./src/data/presets.nix;
    };
}
