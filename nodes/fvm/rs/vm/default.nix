{ support, edges, mods }:

support.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ CoreGraph FsPath FsPathOption ];
  mods = with mods.rs; [ rustfbp capnp ];
}
