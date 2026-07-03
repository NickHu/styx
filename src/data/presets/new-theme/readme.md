# Welcome to your new styx theme!

- `meta.nix` -- theme metadata (`id`, `name`, ...). Change `id` to something unique.
- `templates/` -- Nix templates, exposed to sites as `templates.<path>` (e.g. `templates/page/full.nix` becomes `templates.page.full`).
- `files/` -- static files (css, images, ...) copied as-is into the generated site.

Use this theme from a site's `site.nix` by adding it to the `themes` list, e.g.:

```nix
themes = [
  ./themes/my-theme
];
```

Then declare a page using it:

```nix
pages = {
  index = {
    path = "/index.html";
    title = "Hello world!";
    content = "<p>Hello world!</p>";
    template = templates.page.full;
    layout = templates.layout;
  };
};
```
