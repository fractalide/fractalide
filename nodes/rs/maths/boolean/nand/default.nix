{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ PrimBool ];
  edges = with edges.rs; [ TestNil TestPair TestEnum TestConst TestPoint TestRectangle ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (capnp_0_8_15 {}) ];
  osdeps = with pkgs; [];
}
