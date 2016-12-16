{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ command generic_text];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
