{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc fbp_lexical ];
  crates = with crates; [ rustfbp capnp all__nom.nom_1_2_4 ];
  osdeps = with pkgs; [];
  depsSha256 = "12sygxr7mm5s1lrg665dy7g6f2bq9macmlmfm2bazf3ahnsxgrbw";
}
