{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , fbp_lexical
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc fbp_lexical ];
  depsSha256 = "1m7c2ij8va2fnnbk291bivw2i8g7izwscswvvrvx6qcwk8rd5rdq";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
