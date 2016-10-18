{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_triple
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ list_triple quadruple ];
  depsSha256 = "0qgjahmvc8silwpvyvfbaysg09aq2ljb3ayb6nsl23gkwrk4q8gq";

  meta = with stdenv.lib; {
    description = "Component: Print average, mean, min and max to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/stats;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
