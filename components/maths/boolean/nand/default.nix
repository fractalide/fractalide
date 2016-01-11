{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["maths_boolean"];
  depsSha256 = "132bjwq6x1g3llvlsb0sg34mryry4my5d79qqmkh0cazmb23w4gm";
}
