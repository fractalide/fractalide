{ rs, edges, mods}:

rs.agent {
  src = ./.;
  edges = with edges; [ FsFileDesc CoreLexical ];
  crates = with mods.crates; [ rustfbp capnp nom ];
}
