{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc fbp_lexical ];
  crates = with crates; [ rustfbp capnp nom ];
  osdeps = with pkgs; [];
}
