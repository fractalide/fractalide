{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fs_path fs_path_option ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
