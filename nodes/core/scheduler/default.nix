{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph fs_path fs_path_option prim_text fbp_action ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
