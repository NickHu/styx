env:
let
  template =
    env:
    {
      content,
      type ? "default",
    }:
    ''<span class="label label-${type}">${content}</span>'';
in
template env
