{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["fbp_graph"];
  depsSha256 = "0wdvwxbky4jxddjykr0z25jmvrk1b7hsvphy5icvchnyhzq98ydy";
}
