/*
  A basic page template: renders a title and the page's content.
  Use it in a page declaration with `template = templates.page.full;`.
*/
env: page: ''
  <h1>${page.title or ""}</h1>
  ${page.content or ""}
''
