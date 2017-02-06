{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath PrimText CoreAction ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
