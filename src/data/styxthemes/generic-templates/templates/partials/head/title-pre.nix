env:
let
  template = { templates, ... }: templates.partials.head.meta;
in
template env
