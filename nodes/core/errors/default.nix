{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph fbp_semantic_error file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
