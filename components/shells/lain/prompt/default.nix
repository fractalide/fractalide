{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracs; [generic_text];
  crates = with crates; [];
  depsSha256 = "19mfdmb0myajyryghhck7pqi5z6ri1yndl8kwwdx9w3wa3y142zv";
}
