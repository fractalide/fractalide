{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError FsFileError ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
