env:
let
  template = env: { page, ... }: ''
    ${page.content}
  '';
in
template env
