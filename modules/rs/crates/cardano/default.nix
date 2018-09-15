{ pkgs ? import <nixpkgs> {}
}:

pkgs.callPackage (builtins.toFile "cardano.nix" ''
  { fetchgit, lib }:
  ${builtins.readFile ./cardano.nix}
'') {}
