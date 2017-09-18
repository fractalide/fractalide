{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreGraph CoreSemanticError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
