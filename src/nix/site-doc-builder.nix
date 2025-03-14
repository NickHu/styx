let
  styxPackageRoot = "../../..";
  lockFilePath = "${styxPackageRoot}/share/styx/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';
in {
  pkgs ? import nixpkgs {}
, siteFile
}:

pkgs.callPackage (import ./site-doc.nix) {
  site = (import siteFile) { extraConf.siteUrl = "http://domain.org"; };
}
