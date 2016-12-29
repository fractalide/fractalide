{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
