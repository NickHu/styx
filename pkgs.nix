let
  lock = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile (toString ./flake.lock)));
  nixpkgsSrc = builtins.fetchTree lock.nodes.nixpkgs.locked;
  basePkgs = import nixpkgsSrc {
    system = builtins.currentSystem or "x86_64-linux";
  };
in
  basePkgs.extend (self: _: {
    styx = import ./src/app/cli.nix { pkgs = self; self = ./.; };
  })
