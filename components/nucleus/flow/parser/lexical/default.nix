{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , fbp_lexical
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc fbp_lexical ];
  depsSha256 = "1c57jx2d5mmgrbjcz2pphs33kq9fh9y95m3gzxywv6sx7f6j25j0";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming lexical parser";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
