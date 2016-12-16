{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
