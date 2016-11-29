{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  crates = with crates; [];
  depsSha256 = "0jdh4a6zlh8yrmn1xapmzznv3lzrsjm6k000knvf6ga8hc0y4nc3";
}
