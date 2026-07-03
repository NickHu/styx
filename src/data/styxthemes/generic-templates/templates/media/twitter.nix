env: let
  template = {
    templates,
    lib,
    ...
  }: {
    user,
    width ? null,
    height ? null,
  }:
    with lib; let
      dataWidth = optionalString (width != null) (" " + lib.template.htmlAttr "data-width" (toString width));
      dataHeight = optionalString (height != null) (" " + lib.template.htmlAttr "data-height" (toString height));
    in ''      <a class="twitter-timeline"${dataWidth + dataHeight} href="https://twitter.com/${user}">Tweets by ${user}</a>
          <script async="async" src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
    '';
in
  template env