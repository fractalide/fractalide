{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreGraph ];
  mods = with mods.rs; [ rustfbp capnp ];
}
