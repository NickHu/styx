{pkgs, self}: let
  l = pkgs.lib // builtins;
  version = l.unsafeDiscardStringContext (l.fileContents (self + /VERSION));
  docsSrc = self + /docs;
in
  pkgs.stdenv.mkDerivation {
    pname = "styx-docs";
    inherit version;

    preferLocalBuild = true;
    allowSubstitutes = false;

    nativeBuildInputs = [pkgs.asciidoctor];

    phases = ["installPhase"];

    installPhase = ''
      mkdir -p $out
      asciidoctor ${docsSrc}/index.adoc -o $out/index.html
      substituteInPlace $out/index.html --replace-fail '@version@' '${version}'
      asciidoctor ${docsSrc}/styx-themes.adoc -o $out/styx-themes.html
      substituteInPlace $out/styx-themes.html --replace-fail '@version@' '${version}'
      asciidoctor ${docsSrc}/library.adoc -o $out/library.html
      substituteInPlace $out/library.html --replace-fail '@version@' '${version}'
      cp -r ${docsSrc}/highlight $out/
      if [ -d ${docsSrc}/imgs ]; then
        cp -r ${docsSrc}/imgs $out/
      fi
    '';
  }
