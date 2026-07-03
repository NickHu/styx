# Welcome to your new styx site!

This is a normal Nix flake: `site.nix` is plain data/library code, and
`flake.nix` is what turns it into something you can `nix build`/`nix run`.

## Start

The `site.nix` in this folder generates an empty site. Run `nix build` to
build it (the result is symlinked at `./result`), or `nix run .#serve` to
build it and preview it at <http://127.0.0.1:8080>.

## First steps

Find the line saying `themes = [ ];` in `site.nix` and change it with the following to enable the `generic-templates` theme:

```nix
  themes = [
    styxthemes.generic-templates
  ];
```

The `generic-templates` theme provides a design and a set of templates, but there is no content to generate yet.

So let's create a page! Pages are declared in the pages attribute set. We will start with a basic "Hello world!" index page:

```nix
  pages = {

    index = {
      title    = "Hello world!";
      content  = "<p>Hello world!</p>";
      path     = "/index.html";
      template = templates.page.full;
      layout   = templates.layout;
    };

  };
```

## Commands

- `nix build` -- build the site, output is at `./result`.
- `nix flake check` -- build the site and fail if it doesn't build (useful in CI).
- `nix run .#serve` -- build the site and serve it locally at <http://127.0.0.1:8080>.
- `nix run .#linkcheck` -- build the site, serve it locally and run a link checker against it.
- `nix run .#deploy-gh-pages` -- build the site and commit it to a `gh-pages` branch (in a `./gh-pages` git worktree); push it yourself with `git -C gh-pages push -u origin gh-pages`.
- `nix flake init -t github:styx-static/styx#sample-data` -- generate sample pages/posts in `data/sample`.
- `nix flake new themes/my-theme -t github:styx-static/styx#theme` -- scaffold a new local theme.

The styx documentation (including the bundled themes, with their example
`site.nix`) can be built with `nix build github:styx-static/styx#docs`.

Have fun!
