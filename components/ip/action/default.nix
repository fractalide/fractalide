{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1yrqnbmbbd0548rllyds2c6fa3spziid9a7wcq43lj58cl4djyi5";
}
