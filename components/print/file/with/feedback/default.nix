{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ value_string list_triple];
  crates = with crates; [];
  depsSha256 = "0cx5nl04r03prj79q8hv4pg4ganmjy08rskqhgf4khdl5hr00psh";
}
