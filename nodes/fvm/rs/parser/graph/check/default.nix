{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ CoreGraph CoreSemanticError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
