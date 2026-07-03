env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    {
      embedCode,
      width ? 640,
      height ? 480,
    }:
    ''
      <iframe src='https://www.slideshare.net/slideshow/embed_code/60836660' width='${toString width}' height='${toString height}' allowfullscreen="allowfullscreen" webkitallowfullscreen="webkitallowfullscreen=" mozallowfullscreen="mozallowfullscreen"></iframe>
    '';
in
template env
