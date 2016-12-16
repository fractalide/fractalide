{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ maths_boolean ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
