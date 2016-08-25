{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , fbp_lexical
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc fbp_lexical ];
  depsSha256 = "0b1lf1xh0zb3awdzmv9daklgx1yiiwzqy7vjxkhvn2hggbfmlsh9";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
