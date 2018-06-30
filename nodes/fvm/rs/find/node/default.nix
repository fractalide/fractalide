{ support, edges, mods, pkgs }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ FsPath FsPathOption ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {})  (log_0_4_3 {}) ];
  osdeps = with pkgs; [ nix ];
}
