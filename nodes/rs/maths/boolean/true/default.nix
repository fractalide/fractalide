{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  mods = with mods.rs; [ (rustfbp_0_3_34 {})  (log_0_4_1 {}) ];
  osdeps = with pkgs; [];
}
