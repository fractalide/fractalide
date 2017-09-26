{ buffet
  , genName
  , unifyCapnpEdges
}:
let
  pkgs = buffet.pkgs;
  callPackage = lib.callPackageWith ( pkgs );
  lib = pkgs.lib;
  buildPlatform = pkgs.buildPlatform;
  stdenv = pkgs.stdenv;
  release = buffet.release;
  verbose = buffet.verbose;
  fetchzip = pkgs.fetchzip;
  crates = buffet.mods.rs.crates;
  rust = pkgs.rust.rustc;
  build-rust-package = import ../../../modules/rs/build-rust-package.nix { inherit rust lib buildPlatform stdenv;};
  specialize = callPackage ./specialize.nix  { inherit build-rust-package buffet crates unifyCapnpEdges genName; };
in
{
  inherit build-rust-package;
  executable = specialize { fractalType = "executable"; };
  crate = specialize { fractalType = "crate"; };
  fvm = specialize { fractalType = "fvm"; };
  agent = specialize { fractalType = "agent"; };
}
