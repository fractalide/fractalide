{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ CoreGraph CoreSemanticError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
