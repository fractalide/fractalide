{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [ FsPath FsFileDesc FsFileError ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
