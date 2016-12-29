{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ core_graph ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
