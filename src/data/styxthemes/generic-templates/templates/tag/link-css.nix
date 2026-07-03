env: let
  template = {templates, ...}: attrs:
    templates.tag.link ({
        rel = "stylesheet";
        type = "text/css";
      }
      // attrs);
in
  template env