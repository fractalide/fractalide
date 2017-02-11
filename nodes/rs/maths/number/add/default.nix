{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_i64 ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
