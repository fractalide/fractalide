{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "19chrpf6zpavbn82725s944spmpcrns8ljp5smvd3m2n5hf2hqd6";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
