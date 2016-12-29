{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ core_semantic_error core_graph core_lexical ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
