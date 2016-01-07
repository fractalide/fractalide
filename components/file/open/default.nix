{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file" "path"];
  depsSha256 = "0488ldy13z9vaqkjjkhqb2pi6ra4cw1x4w025p7d77vfrhi2g85w";
}
