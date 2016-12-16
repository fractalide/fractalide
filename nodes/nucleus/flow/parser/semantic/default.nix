{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_semantic_error fbp_graph fbp_lexical ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
