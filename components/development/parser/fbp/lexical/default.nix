{ buildFractalideComponent, filterContracts, genName }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "1lg4pwzad8axr522rfkzgfk0n2m3qjqxng83dfia54l5cyn5c0nm";
}
