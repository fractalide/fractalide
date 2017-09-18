{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreGraph FsPath PrimText CoreAction ];
  mods = with mods.rs; [ rustfbp capnp ];
}
