/*
  return a list of taxonomy terms data for a page in format:

    { path = ...; taxonomy = ...; term = ...; }
*/
env:
let
  template =
    {
      lib,
      templates,
      ...
    }:
    {
      taxonomy,
      page,
    }:
    with lib;
    optionals (hasAttr taxonomy page) map (term: {
      path = lib.pages.mkTaxonomyTermPath taxonomy term;
      inherit taxonomy term;
    }) page."${taxonomy}";
in
template env
