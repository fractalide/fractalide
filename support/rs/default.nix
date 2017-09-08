{ pkgs
  , genName
  , unifySchema
  , buffet
}:
let
  callPackage = lib.callPackageWith ( pkgs );
  lib = pkgs.lib;
  buildPlatform = pkgs.buildPlatform;
  stdenv = pkgs.stdenv;
  release = buffet.release;
  verbose = buffet.verbose;
  fetchzip = pkgs.fetchzip;
  crates = buffet.mods.rs;
  rust = pkgs.rust.rustc;
  mkRustCrate = callPackage ./mkRustCrate.nix  { inherit rust lib buildPlatform stdenv; };
  rustc = callPackage ./rustc.nix  { inherit rust mkRustCrate buffet crates unifySchema genName; };
in
{
  executable = rustc { fractalType = "executable"; };
  crate = rustc { fractalType = "crate"; };
  fvm = rustc { fractalType = "fvm"; };
  agent = rustc { fractalType = "agent"; };
}
