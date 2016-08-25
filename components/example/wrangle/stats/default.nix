{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_triple
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ list_triple quadruple ];
  depsSha256 = "0f816nlsfyvzzy2167sda0368kydgl37ppdnmzxkjlqps19mwy23";

  meta = with stdenv.lib; {
    description = "Component: Print average, mean, min and max to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/stats;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
