{ buffet }:
let
  pkgs = buffet.pkgs;
  callPackage = buffet.pkgs.lib.callPackageWith ( pkgs );
  unifyRustEdges = import ./edge/rs/unify-rust-edges.nix { inherit buffet; };
  genName = callPackage ./genName.nix {};
  subgraph = callPackage ./subgraph.nix { inherit genName; };
  node = callPackage ./node { inherit buffet genName unifyRustEdges; };
  edge = callPackage ./edge { inherit buffet genName; };
in
{
  inherit subgraph edge node unifyRustEdges;
}
