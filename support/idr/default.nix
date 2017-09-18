{ pkgs
  , genName
  , buffet
}:
let
  callPackage = lib.callPackageWith ( pkgs );
  lib = pkgs.lib;
  buildPlatform = pkgs.buildPlatform;
  stdenv = pkgs.stdenv;
  idris = pkgs.haskellPackages.idris;
  gmp = pkgs.gmp;
  gcc = pkgs.gcc;
  build-idris-package = buffet.mods.idr.build-idris-package;
  idr = import ./idr.nix { inherit idris build-idris-package gmp gcc lib stdenv genName;};
in
{
  fvm = idr { fractalType = "fvm"; };
  agent = idr { fractalType = "agent"; };
}
