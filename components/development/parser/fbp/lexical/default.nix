{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "0nq5hxw48iwn834nb28g85b21hxr0wg38k0fbmsvk7h33qh0k0z5";
}
