{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_tuple
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_tuple value_string list_triple ];
  depsSha256 = "1p15wn4a6l4af1vh6qbhg2qcq0gf2aa5gqq90ywf603s654n5x2f";

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
