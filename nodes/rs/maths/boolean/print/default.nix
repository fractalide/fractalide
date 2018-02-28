{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = with edges.capnp; [ PrimBool ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (capnp_0_8_15 {}) (log_0_4_1 {}) (env_logger_0_5_3 {}) ];
  osdeps = with pkgs; [];
}
