{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "1m8ms16188976w93hcd3gw2vmw2m9nh522ywdjc6p2861xv0w9kw";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
