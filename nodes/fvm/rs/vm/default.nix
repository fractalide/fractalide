{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph FsPath FsPathOption ];
  crates = with mods.crates; [ rustfbp capnp ];
}
