{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
