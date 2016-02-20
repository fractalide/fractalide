{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "0s578jxzzidkzcnyd1gglyw5qdaf3hhmw6bm4xhw2c9xzhmjflm0";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
