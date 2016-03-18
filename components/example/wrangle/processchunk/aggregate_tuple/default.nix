{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_tuple" "value_string" "list_triple"];
  depsSha256 = "1q0ccjn78rv6x983582grz3s1ssccbihs49mca958h95vsc11dlh";

  meta = with stdenv.lib; {
    description = "Component: aggregate a stream of tuples such that `(airline, 1000)`, `(airline, 2000)`, `(airline, 1000)`
    looks like this: `(airline, 1000, 2)`, `(airline, 2000, 1)` i.e. (type, price, count)";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/aggregate_tuple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
