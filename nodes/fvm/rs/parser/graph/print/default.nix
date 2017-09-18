{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph ];
  mods = with mods.rs; [ rustfbp capnp ];
}
