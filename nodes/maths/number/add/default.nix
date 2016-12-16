{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ maths_number ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
