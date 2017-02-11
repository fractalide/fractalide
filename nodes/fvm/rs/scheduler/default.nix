{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath PrimText CoreAction ];
  crates = with mods.crates; [ rustfbp capnp ];
}
