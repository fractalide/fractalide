{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ CoreSemanticError CoreGraph CoreLexical ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
