{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph path generic_text fbp_action ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0sakyczg4yc99q2f3vpwcyp4hh4dd86rx5x9drkzr1jz5izxfzyi";
}
