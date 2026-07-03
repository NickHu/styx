# Contributing to Styx

Thank you for being interested in contributing to this project!
Feel free to ask questions on the [issue tracker](https://github.com/styx-static/styx/issues).

## Setting up a development environment

Setting up a development environment requires [`nix`](https://nixos.org/nix/) with flakes enabled.

### Preparation

#### Getting the repository

Clone this repository:

```
$ git clone https://github.com/styx-static/styx.git
```

### Devshell

Enter the devshell:

```
$ direnv allow || nix develop -c "$SHELL"
```

### Running checks

Run the full test battery:

```
$ nix flake check
```

Open the documentation:

```
$ nix run .#doc
```

### Themes

Build the bundled theme example site:

```
$ nix build .#checks.x86_64-linux.generic-templates-site
```

Loading the generic-templates example site in `nix repl`:

```
$ nix repl ./repl.nix
> themes = out.legacyPackages.styxthemes

nix-repl> site = import "${themes.generic-templates}/example/site.nix" {
            pkgs = out.packages;
            styxlib = out.lib;
            styxthemes = themes;
            sampleData = ./src/data/presets/sample-data/data/sample;
          }

nix-repl> site.conf
{ siteUrl = "https://styx-static.github.io/styx-theme-generic-templates"; theme = { ... }; }
```

## Commit policy

Please run the tests before any commit:

```
$ nix flake check
```
