{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path value_string ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
