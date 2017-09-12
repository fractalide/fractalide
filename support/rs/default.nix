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
  crates = buffet.mods.rs.crates;
  rust = pkgs.rust.rustc;
  buildRustCode = import ./buildRustCode.nix { inherit rust lib buildPlatform stdenv;};
  specialize = callPackage ./specialize.nix  { inherit buildRustCode buffet crates unifySchema genName; };
in
{
  buildRustCode = buildRustCode;
  executable = specialize { fractalType = "executable"; };
  crate = specialize { fractalType = "crate"; };
  fvm = specialize { fractalType = "fvm"; };
  agent = specialize { fractalType = "agent"; };
}
