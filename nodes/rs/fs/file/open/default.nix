{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [ FsPath FsFileDesc FsFileError ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {})  (log_0_4_5 {}) ];
  osdeps = with pkgs; [];
}
