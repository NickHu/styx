{pkgs, self, docs, styxlib, styxthemes}: let
  l = pkgs.lib // builtins;

  # Synthetic site loaded with every bundled theme, used only to regenerate
  # docs/styx-themes-generated.adoc and docs/library-generated.adoc.
  docSiteFn = _: {
    loaded = styxlib.themes.load {
      lib = styxlib;
      themes = l.reverseList (l.attrValues styxthemes);
      config = [{siteUrl = "http://domain.org";}];
      env = {
        data = {};
        pages = {};
      };
    };
  };

  docThemes = docs.site docSiteFn {};
  docLibrary = docs.library docSiteFn {};
in {
  update-doc = pkgs.writeShellApplication {
    name = "update-doc";
    text = ''
      repoRoot="$(git rev-parse --show-toplevel)"
      target="$(readlink -f -- "$repoRoot/docs/")"

      if ! cmp "${docThemes}/themes-generated.adoc" "$target/styx-themes-generated.adoc"
      then
        cp ${docThemes}/themes-generated.adoc "$target/styx-themes-generated.adoc" --no-preserve=all
        mkdir -p "$target/imgs"
        cp ${docThemes}/imgs/* "$target/imgs/" --no-preserve=all 2>/dev/null || true
        echo "Themes documentation updated!"
      fi

      if ! cmp "${docLibrary}/library-generated.adoc" "$target/library-generated.adoc"
      then
        cp ${docLibrary}/library-generated.adoc "$target/library-generated.adoc" --no-preserve=all
        echo "Library documentation updated!"
      fi
    '';
  };
}
