{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph fbp_semantic_error file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "17qiz2qfxkrjiq487scyfgdprlxkb1pc0z5z79b2y6l2vpmhvw5d";
}
