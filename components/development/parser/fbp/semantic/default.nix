{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["fbp_graph" "fbp_lexical"];
  depsSha256 = "1mzk49cw0ygamm0s1003zsxxpqj93i3x7yyjyxysngcxn39h4ly9";
}
