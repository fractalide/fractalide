{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ CoreSemanticError CoreGraph CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp ];
}
