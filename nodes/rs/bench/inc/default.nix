{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimU64 ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
