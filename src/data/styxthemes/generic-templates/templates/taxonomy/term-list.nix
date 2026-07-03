env:
let
  template =
    {
      templates,
      lib,
      ...
    }:
    with lib;
    taxonomyData:
    let
      taxonomy = lib.proplist.propKey taxonomyData;
      terms = lib.proplist.propValue taxonomyData;
    in
    map (
      prop:
      let
        term = lib.proplist.propKey prop;
        values = lib.proplist.propValue prop;
      in
      {
        path = lib.pages.mkTaxonomyTermPath taxonomy term;
        inherit term taxonomy values;
        count = length values;
      }
    ) terms;
in
template env
