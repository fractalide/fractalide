{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["fbp_graph" "file_error" "fbp_semantic_error"];
  depsSha256 = "0wdvwxbky4jxddjykr0z25jmvrk1b7hsvphy5icvchnyhzq98ydy";
}
