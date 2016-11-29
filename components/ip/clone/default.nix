{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "0jdh4a6zlh8yrmn1xapmzznv3lzrsjm6k000knvf6ga8hc0y4nc3";
}
