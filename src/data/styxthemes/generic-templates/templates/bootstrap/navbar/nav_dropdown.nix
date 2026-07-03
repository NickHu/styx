env: let
  template = {
    lib,
    conf,
    templates,
    ...
  }: {
    title,
    items,
    caret ? ''<span class="caret"></span>'',
    ...
  }:
    with lib; ''
      <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">${title}${caret}</a>
      <ul class="dropdown-menu">
      ${lib.template.mapTemplate (item: templates.bootstrap.navbar.nav_item {inherit item;}) items}
      </ul>
      </li>'';
in
  template env