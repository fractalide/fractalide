{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ FsFileDesc FsPath FsFileError ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
