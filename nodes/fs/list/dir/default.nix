{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fs_list_path fs_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
