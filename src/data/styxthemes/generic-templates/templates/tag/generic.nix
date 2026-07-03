/*
generic template for a tag

templates.tag.generic { tag = "div"; content = "hello world" }
*/
env: let
  template = {lib, ...}: {
    tag,
    content,
    ...
  } @ args:
    with lib; let
      attrs = lib.template.htmlAttrs (removeAttrs args ["tag" "content"]);
    in "<${tag}${optionalString (attrs != "") " ${attrs}"}>${content}</${tag}>";
in
  template env