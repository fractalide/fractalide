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
  idris = pkgs.haskellPackages.idris;
  gmp = pkgs.gmp;
  gcc = pkgs.gcc;
  build-idris-package = buffet.mods.idr.build-idris-package;
  specialize = import ./specialize.nix { inherit idris build-idris-package gmp gcc lib stdenv genName unifyCapnpEdges;};
in
{
  fvm = specialize { fractalType = "fvm"; };
  agent = specialize { fractalType = "agent"; };
}
