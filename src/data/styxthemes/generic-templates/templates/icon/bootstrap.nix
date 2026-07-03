env:
let
  template = env: icon: ''<span class="glyphicon glyphicon-${icon}" aria-hidden="true"></span>'';
in
with env.lib.template;
template env
