{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ PrimBool ];
  edges = with edges.rs; [ TestNil TestPair TestEnum TestConst TestPoint TestRectangle ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
