{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ value_string list_triple];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
