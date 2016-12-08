{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1yrqnbmbbd0548rllyds2c6fa3spziid9a7wcq43lj58cl4djyi5";
}
