{ buffet }:
let
  pkgs = buffet.pkgs;
  callPackage = buffet.pkgs.lib.callPackageWith ( pkgs );
  unifyCapnpEdges = callPackage ./edge/capnp/unifyCapnpEdges.nix { inherit buffet; };
  genName = callPackage ./genName.nix {};
  subgraph = callPackage ./subgraph.nix { inherit genName; };
  imsg = callPackage ./imsg.nix { inherit buffet; };
  node = callPackage ./node { inherit buffet genName unifyCapnpEdges; };
  edge = callPackage ./edge { inherit buffet genName; };
in
{
  inherit subgraph imsg edge node;
}
