{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (log_0_4_5 {}) (env_logger_0_5_13 {}) ];
  osdeps = with pkgs; [];
}
