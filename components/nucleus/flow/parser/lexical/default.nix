{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , fbp_lexical
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc fbp_lexical ];
  depsSha256 = "12sygxr7mm5s1lrg665dy7g6f2bq9macmlmfm2bazf3ahnsxgrbw";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
