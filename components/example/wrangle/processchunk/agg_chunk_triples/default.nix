{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_tuple" "value_string" "list_triple"];
  depsSha256 = "1ncdxn4jdc692ky9hhgh5q23q8r2hp93vnwignhk2a2hsb1kn8g1";

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
