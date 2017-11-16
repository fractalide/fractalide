{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  # capnp_edges = with edges.capnp; [ PrimU64 ];
  edges = with edges.rs; [ TestPair ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
