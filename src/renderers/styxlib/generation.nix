# Page and site generation functions
lib: nixpkgs: styxlib:
with lib;
assert assertMsg (hasAttr "utils" styxlib) "styxlib.generation uses styxlib.utils";
with styxlib.utils;
rec {
  generatePage = page: page.layout (page.template page);

  mkSite =
    {
      meta ? { },
      files ? [ ],
      pageList ? [ ],
      substitutions ? { },
      preGen ? "",
      postGen ? "",
      genPageFn ? generatePage,
      pagePathFn ? (page: page.path),
    }:
    let
      env = {
        meta = {
          platforms = lib.platforms.all;
        }
        // meta;
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      name = meta.name or "styx-site";
    in
    nixpkgs.runCommand name env ''
      shopt -s globstar
      mkdir -p $out

      # check if a file is a text file
      text_file () {
        ${nixpkgs.file}/bin/file $1 | grep text | cut -d: -f1
      }

      # run substitutions on a file
      # output results to subs
      run_subs () {
        cp $1 subs && chmod u+rw subs
        ${concatMapStringsSep "\n" (
          set:
          let
            key = head (attrNames set);
            value = head (attrValues set);
          in
          ''
            substituteInPlace subs \
              --subst-var-by "${key}" "${toString value}"
          ''
        ) (setToList substitutions)}
      }

      ${preGen}

      # FILES
      # files are copied only if necessary, else they are just linked from the source
      ${concatMapStringsSep "\n" (filesDir: ''
        for file in ${filesDir}/**/*; do

          # Ignoring folders
          if [ -d "$file" ]; then continue; fi

          # output path
          path=$(realpath -s --relative-to="${filesDir}" "$file")
          mkdir -p $(dirname $out/$path)

          if [ $(text_file $file) ]; then
            input=$file
            hasSubs=
            run_subs $file

            if [ $(cmp --silent subs $file || echo 1) ]; then
              input=subs
              hasSubs=1
            fi

            if [ "$hasSubs" ]; then
              cp "$input" "$out/$path"
            else
              ln -s "$input" "$out/$path"
            fi

          else
            [ -f "$out/$path" ] && rm "$out/$path"
            ln -s "$file" "$out/$path"
          fi
        done;
      '') files}

      # PAGES
      ${concatMapStringsSep "\n" (page: ''
        outPath="$out${pagePathFn page}"
        page=${nixpkgs.writeText "${name}-page" (genPageFn page)}
        mkdir -p "$(dirname "$outPath")"
        run_subs "$page"
        if [ $(cmp --silent subs $page || echo 1) ]; then
          cp "subs" "$outPath"
        else
          ln -s "$page" "$outPath"
        fi
      '') pageList}

      ${postGen}
    '';

  pagesToList =
    {
      pages,
      default ? { },
    }:
    let
      pages' = attrValues pages;
    in
    foldr (
      p: acc:
      if isList p then
        acc ++ (map (recursiveUpdate default) p)
      else if (p ? _type && p._type == "pages") then
        acc ++ (map (recursiveUpdate default) p.pages)
      else
        acc ++ [ (recursiveUpdate default p) ]
    ) [ ] pages';
}
