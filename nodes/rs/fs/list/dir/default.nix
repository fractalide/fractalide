{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.capnp; [ FsPath FsListPath ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
