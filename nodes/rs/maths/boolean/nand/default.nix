{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [ TestNil TestPair TestEnum TestConst TestPoint TestRectangle ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (log_0_4_5 {}) (cardano_0_1_0 {}) ];
  osdeps = with pkgs; [];
}
