env: let
  template = {
    lib,
    templates,
    ...
  }:
    lib.template.normalTemplate (page: rec {
      title = page.title or page.taxonomy;
      content = ''
        <h1>${title}</h1>
        <ul>
        ${lib.template.mapTemplate (
          t: ''
            <li>${templates.tag.ilink {
              to = t.path;
              content = t.term;
            }} (${toString t.count})</li>''
        ) (templates.taxonomy.term-list page.taxonomyData)}
        </ul>
      '';
    });
in
  template env