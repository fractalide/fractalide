{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_desc" "fbp_lexical"];
  depsSha256 = "1xax4060vfd6a50wyjnhjdh7gwpk8snwlkf8qacbnpk5f32yy5sv";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
