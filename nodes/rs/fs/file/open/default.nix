{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ FsFileDesc FsPath FsFileError ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
