{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph path option_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
