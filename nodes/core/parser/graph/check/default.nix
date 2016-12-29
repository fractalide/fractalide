{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ core_graph core_semantic_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
