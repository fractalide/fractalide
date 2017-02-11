{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimText ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
