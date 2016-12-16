{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc path file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
