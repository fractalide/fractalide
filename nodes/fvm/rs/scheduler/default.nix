{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath PrimText CoreAction ];
  mods = with mods.rs; [ rustfbp capnp ];
}
