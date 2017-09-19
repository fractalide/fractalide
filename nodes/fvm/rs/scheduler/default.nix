{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreGraph FsPath PrimText CoreAction ];
  mods = with mods.rs; [ rustfbp capnp ];
}
