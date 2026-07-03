env: let
  template = {
    templates,
    lib,
    ...
  }: {
    id,
    height ? 315,
    width ? 560,
  }: ''    <iframe width="${toString width}" height="${toString height}" src="https://www.youtube.com/embed/${id}?ecver=1" frameborder="0" allowfullscreen="allowfullscreen"></iframe>
  '';
in
  template env