{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ CoreGraph CoreSemanticError FsFileError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
