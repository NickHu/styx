env:
let
  template =
    { templates, ... }:
    args:
    templates.lib.css.bootstrap
    + templates.lib.css.font-awesome
    + templates.lib.css.highlightjs
    + templates.lib.css.googlefonts
    + (templates.partials.head.css-custom args)
    + (templates.partials.head.css-extra args);
in
template env
