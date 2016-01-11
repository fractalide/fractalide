{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["maths_number"];
  depsSha256 = "18l4xywaf9yzz5ak5b3q045cmdz0acpxlnnnn8l8mg0bggyicrpq";
}
