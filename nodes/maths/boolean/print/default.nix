{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_bool ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
