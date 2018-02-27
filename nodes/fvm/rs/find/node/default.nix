{ support, edges, mods, pkgs }:

support.node.rs.agent {
  src = ./.;
  edges = with edges.rs; [ FsPath FsPathOption ];
  mods = with mods.rs; [ (rustfbp_0_3_34 {}) (capnp_0_8_15 {}) (log_0_4_1 {}) ];
  osdeps = with pkgs; [ nix ];
}
