{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ PrimU64 ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
