{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ CoreGraph FsPath FsPathOption ];
  mods = with mods.rs; [ rustfbp capnp ];
}
