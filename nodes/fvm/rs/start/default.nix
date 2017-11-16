{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ CoreAction ];
  mods = with mods.rs; [ rustfbp capnp ];
}
