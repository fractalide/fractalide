{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ app_counter ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
