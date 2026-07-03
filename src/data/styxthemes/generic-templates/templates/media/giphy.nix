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
      height,
      width,
    }:
    ''
      <iframe src="//giphy.com/embed/${id}" width="${toString width}" height="${toString height}" frameBorder="0" class="giphy-embed" allowFullScreen="allowFullScreen"></iframe>
    '';
in
template env
