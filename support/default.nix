{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs );
  capnpcPlugins = callPackage ./capnpcPlugins { inherit buffet; };
  unifySchema = callPackage ./unifySchema.nix { inherit capnpcPlugins; };
  genName = callPackage ./genName.nix {};
  subgraph = callPackage ./subgraph.nix { inherit genName; };
  edge = callPackage ./edge.nix { inherit genName; };
  imsg = callPackage ./imsg.nix { inherit unifySchema; };
  rs = callPackage ./rs { inherit genName unifySchema buffet; };
  purs = callPackage ./purs { inherit genName unifySchema buffet; };
  idr = callPackage ./idr { inherit genName buffet; };
in
{
  inherit subgraph edge imsg rs purs idr;
}
