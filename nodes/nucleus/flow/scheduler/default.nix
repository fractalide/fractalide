{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph path generic_text fbp_action ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
