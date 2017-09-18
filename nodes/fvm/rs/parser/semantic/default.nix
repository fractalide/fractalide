{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreSemanticError CoreGraph CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp ];
}
