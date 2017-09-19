{ support, edges, mods}:

support.node.rs.agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ FsFileDesc CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp nom ];
}
