{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimBool ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
