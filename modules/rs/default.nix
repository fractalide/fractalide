{ buffet }:
let
  fetchgit = buffet.pkgs.fetchgit;
  buildRustCrate = buffet.pkgs.buildRustCrate;
  buildPlatform = buffet.pkgs.stdenv.buildPlatform;
  lib = buffet.pkgs.lib;
  crates = import ./crates { inherit lib buildRustCrate fetchgit buildPlatform; };
in
crates
