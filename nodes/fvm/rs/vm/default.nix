{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath FsPathOption ];
  mods = with mods.rs; [ rustfbp capnp ];
}
