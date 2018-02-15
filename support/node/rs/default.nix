{ buffet
  , genName
  , unifyCapnpEdges
  , unifyRustEdges
}:
let
  pkgs = buffet.pkgs;
  callPackage = lib.callPackageWith ( pkgs );
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  release = buffet.release;
  verbose = buffet.verbose;
  buildRustCrate = pkgs.buildRustCrate;
  transformNodeIntoCrate = import ./transform-node-into-crate.nix { stdenv = pkgs.stdenv; };
  specialize = callPackage ./specialize.nix  { inherit buildRustCrate unifyCapnpEdges unifyRustEdges transformNodeIntoCrate buffet genName; };
in
{
  inherit buildRustCrate;
  executable = specialize;
  crate = specialize;
  fvm = specialize;
  agent = specialize;
}
