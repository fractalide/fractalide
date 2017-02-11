{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimU64 ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
