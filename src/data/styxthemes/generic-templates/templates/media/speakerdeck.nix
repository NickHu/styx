env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    {
      id,
      slide ? null,
    }:
    with lib;
    templates.tag.script (
      {
        src = "//speakerdeck.com/assets/embed.js";
        class = "speakerdeck-embed";
        data-id = id;
        async = "async";
        data-ratio = "1.33333333333333";
      }
      // (optionalAttrs (slide != null) { data-slide = toString slide; })
    );
in
template env
