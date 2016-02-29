{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file" "fbp_lexical"];
  depsSha256 = "0r5lgcrilhnyd3c9v25mqbs6f41ff3zwlwczi0xh7vg14xqzs24w";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
