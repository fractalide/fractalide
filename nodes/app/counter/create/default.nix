{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ app_counter js_create];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
