{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreSemanticError CoreGraph CoreLexical ];
  crates = with mods.crates; [ rustfbp capnp ];
}
