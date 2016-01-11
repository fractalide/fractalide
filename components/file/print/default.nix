{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file"];
  depsSha256 = "1nfllagp9cgmk0gr6g47iqrbvm7cs3d81482krgj0la8m5p7lgci";
}
