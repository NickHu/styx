env:
let
  template = { lib, ... }: { content }: "<pre><code>${lib.escapeHTML content}</pre></code>";
in
template env
