{ buffet }:
let
  fetchgit = buffet.pkgs.fetchgit;
  buildRustCrate = buffet.pkgs.buildRustCrate;
  buildPlatform = buffet.pkgs.stdenv.buildPlatform;
  lib = buffet.pkgs.lib;
  unifyRustEdges = buffet.support.unifyRustEdges;
  edgesModule = buffet.edgesModule;
  crates = import ./crates { inherit lib buildRustCrate fetchgit buildPlatform edgesModule; };
in
crates
