{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [ FsFileDesc ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
