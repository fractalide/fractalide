{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["maths_number"];
  depsSha256 = "11ahbhclxm6f9g0x1f80hbnkm9wbc08zrsqwj5rlnbjyp05pzj3r";
}
