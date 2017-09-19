{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ FsPath FsListPath ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
