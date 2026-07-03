# Built-in markup parsers and converters (used by styxlib.data).
{ pkgs, parsers }:
let
  l = pkgs.lib // builtins;
in
{
  markdown = {
    extensions = [
      "md"
      "mdown"
      "markdown"
    ];
    converter = f: "${l.getExe pkgs.pandoc} ${f} > $out";
    parser = f: "${l.getExe parsers.markdown} < ${f} > $out";
  };
  asciidoc = {
    extensions = [
      "adoc"
      "asciidoc"
    ];
    converter = f: "${l.getExe pkgs.asciidoctor} -b xhtml5 -s -a showtitle -o- ${f} > $out";
    parser = f: "${l.getExe parsers.asciidoc} < ${f} > $out";
  };
}
