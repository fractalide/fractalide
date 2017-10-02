{ support, edges, mods}:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ FsFileDesc CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp nom ];
}
