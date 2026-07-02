{ pkgs, self }: let
  l = pkgs.lib // builtins;
  inherit (pkgs) stdenv;
in
  stdenv.mkDerivation rec {
    preferLocalBuild = true;
    allowSubstitutes = false;

    inherit (pkgs) runtimeShell;

    pname = "styx";
    version = l.unsafeDiscardStringContext (l.fileContents (self + /VERSION));

    bin = pkgs.writeShellApplication {
      name = pname;
      excludeShellChecks = ["SC2317"];
      runtimeInputs = [pkgs.caddy pkgs.lychee pkgs.jq pkgs.nix];
      text = l.fileContents ./cli/styx.sh;
    };

    nativeBuildInputs = [pkgs.asciidoctor];

    phases = ["installPhase" "installCheckPhase"];

    installPhase = ''
      mkdir $out
      install -D -m 777 ${bin}/bin/styx       $out/bin/styx
      substituteInPlace                       $out/bin/styx                        --subst-var version

      # Compatibility
      cp -r ${self}/* $out

      # Documentation
      mkdir -p                                $out/share/doc/styx
      asciidoctor \
      ${self}/docs/index.adoc       -o $out/share/doc/styx/index.html
      substituteInPlace                       $out/share/doc/styx/index.html       --subst-var version
      asciidoctor \
      ${self}/docs/styx-themes.adoc -o $out/share/doc/styx/styx-themes.html
      substituteInPlace                       $out/share/doc/styx/styx-themes.html --subst-var version
      asciidoctor \
      ${self}/docs/library.adoc     -o $out/share/doc/styx/library.html
      substituteInPlace                       $out/share/doc/styx/library.html     --subst-var version
      cp -r ${self}/docs/highlight     $out/share/doc/styx/
      cp -r ${self}/docs/imgs          $out/share/doc/styx/
    '';

    meta = {
      description = "Nix based static site generator";
      maintainers = with l.maintainers; [ericsagnes siraben blaggacao];
      platforms = l.platforms.all;
      mainProgram = pname;
    };

    # compat with evtl old themes that use the old calling convention
    passthru = {
      # import pkgs.styx.themes
      themes = "${l.toString self}/themes-compat.nix";
    };
  }
