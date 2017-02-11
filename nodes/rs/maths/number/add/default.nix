{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_i64 ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
