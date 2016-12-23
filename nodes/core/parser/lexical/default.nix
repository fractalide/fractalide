{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc fbp_lexical ];
  crates = with crates; [ rustfbp capnp all__nom.nom_2_0_1 ];
  osdeps = with pkgs; [];
}
