{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ PrimBool ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
