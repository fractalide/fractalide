{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_tuple
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_tuple value_string list_triple ];
  depsSha256 = "0j8i33307mlphrdp215x0ss3z615ifap3xmda2gs3di55zxh3xsc";

  meta = with stdenv.lib; {
    description = "Component: aggregate a stream of tuples such that
    input: `(airline, 1000, 3)`, `(airline, 2000,2)`, `(airline, 1000,5)`
    output: `(airline, 1000, 8)`, `(airline, 2000, 2)`
     a triple is (type, price, count)";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/aggregate_tuple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
