{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc list_command ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
