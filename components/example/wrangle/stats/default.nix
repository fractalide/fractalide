{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_triple
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ list_triple quadruple ];
  depsSha256 = "1gxqzfvanmh130xlmqhh9rbgs3fz43rhvqfsaj65s80d4ph17j7m";

  meta = with stdenv.lib; {
    description = "Component: Print average, mean, min and max to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/stats;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
