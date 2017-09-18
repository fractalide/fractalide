{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath PrimText CoreAction ];
  mods = with mods.rs; [ rustfbp capnp ];
}
