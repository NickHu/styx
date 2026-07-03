/*
  The layout wraps every page's rendered content (see `page/full.nix`) in the
  site's HTML shell. `env` carries the merged configuration/library/templates,
  `content` is the string returned by the page's own template.
*/
env: content: ''
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>${env.conf.theme.site.title or "My Site"}</title>
    </head>
    <body>
      ${content}
    </body>
  </html>
''
