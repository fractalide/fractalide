{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ value_string list_triple];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0cx5nl04r03prj79q8hv4pg4ganmjy08rskqhgf4khdl5hr00psh";
}
