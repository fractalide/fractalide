{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError FsFileError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
