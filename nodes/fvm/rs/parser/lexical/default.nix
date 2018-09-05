{ support, edges, mods}:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ FsFileDesc CoreLexical ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {})  (nom_3_2_1 {}) (log_0_4_5 {}) ];
}
