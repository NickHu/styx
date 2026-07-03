env:
let
  template = { templates, ... }: args: ''
    <head>
    ${
      templates.partials.head.title-pre args
      + templates.partials.head.title args
      + templates.partials.head.title-post args
    }</head>
  '';
in
template env
