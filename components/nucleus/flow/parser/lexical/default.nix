{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , fbp_lexical
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc fbp_lexical ];
  depsSha256 = "1filzf3414q2fycdp3cm5dmz4dfns45i45i9qn56ync5wp3axshs";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
