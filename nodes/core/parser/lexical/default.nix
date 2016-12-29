{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fs_file_desc core_lexical ];
  crates = with crates; [ rustfbp capnp nom ];
  osdeps = with pkgs; [];
}
