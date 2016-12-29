{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fs_file_desc fs_path fs_file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
