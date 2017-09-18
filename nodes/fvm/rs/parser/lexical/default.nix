{ support, edges, mods}:

support.rs.agent {
  src = ./.;
  edges = with edges.capnp; [ FsFileDesc CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp nom ];
}
