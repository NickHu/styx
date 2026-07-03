# Styx

![Build Status](https://github.com/styx-static/styx/workflows/Build/badge.svg)

The purely functional static site generator written in the Nix expression language.

## Features

Among other things, Styx has the following features:

### Easy to get started

Styx has no dependency other than Nix. Create a new site from the flake template:

```bash
mkdir my-site && cd my-site
nix flake init -t github:styx-static/styx#default
nix build
nix run .#serve
```

### Multiple content support

Styx supports content in Markdown, AsciiDoc and Nix format.
Styx also extends AsciiDoc and Markdown with custom operators that can split a single markup file into many pages.

### Embedded nix

Nix can be [embedded in markup files](https://styx-static.github.io/styx-theme-showcase/posts/2016-09-17-media.html)!

### Handling of sass/scss

Upon site rendering, Styx will automatically convert SASS and SCSS files.

### Template framework

The `generic-template` theme provides a template framework that can be leveraged to easily create new themes or sites.
Thank to this a theme like Hyde consists only in about 120 lines of Nix templates.

### Configuration interface

Styx sites use a configuration interface à la NixOS modules.
Every configuration declaration is type-checked, and documentation can be generated from that interface.

### Linkcheck

Link checking is available via the site template's flake app:

```bash
nix run .#linkcheck
```

This serves the built site locally and runs [lychee](https://github.com/lycheeverse/lychee) against it.

### Themes

Styx supports themes. Multiple themes can be used, mixed and extended at the same time.
This makes it very easy to adapt an existing theme.
Official themes can also be used without any implicit installation, declaring the used theme(s) in `site.nix` is enough!

### Documentation

Styx ships a complete HTML manual as a flake package:

```bash
nix run github:styx-static/styx#doc
```

Theme and library reference pages can be regenerated for a loaded site with `nix run .#update-doc` in the styx repository.

## Getting started

Styx is consumed as a flake input in your site's `flake.nix`. Scaffold a new site with:

```sh
nix flake init -t github:styx-static/styx#default
```

Read the generated `readme.md` or open the manual:

```sh
nix run github:styx-static/styx#doc
```

## Examples

The official Styx site is an example of a basic software site with release news. It has some interesting features like:

- generating the documentation for every version of styx
- generating a page for every official theme

See [site.nix](https://github.com/styx-static/styx-site/blob/master/site.nix) for implementation details.

Bundled theme example sites are built by `nix flake check` in this repository (for example `checks.x86_64-linux.showcase-site`).

## As a Nix laboratory

This repository is also a playground for more exotic nix usages and experiments:

- The flake exposes `lib`, bundled themes, documentation, templates, and a `checks` output for CI.

- Library functions and theme templates use special functions (`documentedFunction` and `documentedTemplate`) that allow automatically generating documentation and tests.
  Library function tests can print a coverage or a report (with pretty printing):

      ```
      $ nix build .#checks.x86_64-linux.lib-report && cat ./result
      $ nix build .#checks.x86_64-linux.lib-coverage && cat ./result
      ```

- [src/renderers/docs/library.nix](./src/renderers/docs/library.nix) is a nix expression that generate an AsciiDoc documentation from the library `documentedFunction`s ([example](https://styx-static.github.io/styx-site/documentation/library.html)).

- [src/renderers/docs/site.nix](./src/renderers/docs/site.nix) is a nix expressions that automatically generate documentation for styx themes, including configuration interface and templates ([example](https://styx-static.github.io/styx-site/documentation/styx-themes.html)). Regenerate the committed excerpts with `nix run .#update-doc`.

- [parsimonious](https://github.com/erikrose/parsimonious) is used to do some [voodoo](src/app/parsers/) on markup files to turn them into valid nix expressions, so nix expressions can be embedded in Markdown or AsciiDoc.

## Links

- [Official site](https://styx-static.github.io/styx-site/)
- [Documentation](https://styx-static.github.io/styx-site/documentation/)

## Contributing

See [contributing.md](./contributing.md).

## Feedback

Any question or issue should be posted in the [github issue tracker](https://github.com/styx-static/styx/issues).
Themes and features requests are welcome!
And please let me know if you happen to run a site on styx!
