{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file"];
  depsSha256 = "0czsgx367510wiivyxagmkc1jy9qddbmqqp8vy2h0r8m01v0ablh";
}
