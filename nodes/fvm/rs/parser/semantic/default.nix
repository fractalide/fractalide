{ support, edges, mods }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ CoreGraph CoreLexical CoreSemanticError ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {})  (log_0_4_5 {}) ];
}
