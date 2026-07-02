{ pkgs }:
pkgs.mkShell {
  name = "styx";
  packages = with pkgs; [pandoc asciidoctor statix];
}
