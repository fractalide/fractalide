{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreSemanticError CoreGraph CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp ];
}
