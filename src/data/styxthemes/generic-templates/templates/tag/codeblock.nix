env: let
  template = {lib, ...}: {content}: "<pre><code>${lib.template.escapeHTML content}</pre></code>";
in
  template env