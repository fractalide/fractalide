{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ FsFileDesc CoreLexical ];
  crates = with crates; [ rustfbp capnp nom ];
  osdeps = with pkgs; [];
}
