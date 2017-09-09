{ buffet }:
let
  lib = buffet.pkgs.lib;
  buildPlatform = buffet.pkgs.buildPlatform;
  stdenv = buffet.pkgs.stdenv;
  fetchzip = buffet.pkgs.fetchzip;
  rust = buffet.pkgs.rust.rustc;
  release = buffet.release;
  verbose = buffet.verbose;
  mkRustCrate = import ../../support/rs/mkRustCrate.nix  { inherit rust lib buildPlatform stdenv; };
  crates = import ./crates { inherit mkRustCrate fetchzip release verbose; };
in
crates
