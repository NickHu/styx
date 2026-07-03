env: let
  template = {
    lib,
    templates,
    ...
  }:
    lib.template.normalTemplate (page: rec {
      title = page.title or "${page.taxonomy}: ${page.term}";
      content = ''
        <h1>${title}</h1>
        <ul>
        ${lib.template.mapTemplate (value: ''
          <li>${templates.tag.ilink {
            to = value;
          }}</li>'')
        page.values}
        </ul>
      '';
    });
in
  template env