{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError FsFileError ];
  crates = with mods.crates; [ rustfbp capnp ];
}
