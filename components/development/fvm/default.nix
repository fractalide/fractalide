{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["fbp_graph" "file_error" "fbp_semantic_error"];
  depsSha256 = "0w8b6mldsxqn807sb232m2xb7d9vzlyh5f8rqm6vf5555by3fzw7";
}
