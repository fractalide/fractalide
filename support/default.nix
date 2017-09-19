{ buffet }:
let
  pkgs = buffet.pkgs;
  callPackage = buffet.pkgs.lib.callPackageWith ( pkgs );
  capnpcPlugins = callPackage ./capnpcPlugins { inherit buffet; };
  unifySchema = callPackage ./unifySchema.nix { inherit capnpcPlugins; };
  genName = callPackage ./genName.nix {};
  subgraph = callPackage ./subgraph.nix { inherit genName; };
  imsg = callPackage ./imsg.nix { inherit unifySchema; };
  node = callPackage ./node { inherit pkgs genName unifySchema buffet; };
  edge = callPackage ./edge { inherit genName buffet; };
in
{
  inherit subgraph imsg edge node;
}
