env: let
  template = {
    templates,
    lib,
    ...
  }: {
    id,
    height ? 360,
    width ? 640,
  }:
    with lib; ''      <iframe src="https://player.vimeo.com/video/${id}" width="${toString width}" height="${toString height}" frameborder="0" webkitallowfullscreen="webkitallowfullscreen=" mozallowfullscreen="mozallowfullscreen=" allowfullscreen="allowfullscreen"></iframe>
    '';
in
  template env