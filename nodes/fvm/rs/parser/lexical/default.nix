{ support, edges, mods}:

support.rs.agent {
  src = ./.;
  edges = with edges; [ FsFileDesc CoreLexical ];
  mods = with mods.rs; [ rustfbp capnp nom ];
}
