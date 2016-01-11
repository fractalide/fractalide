{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["maths_boolean"];
  depsSha256 = "0vzyz3ph1q19sphxrpji4sz05fd8856ilz0swy2580hirl3a5qs9";
}
