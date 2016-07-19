{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_triple"];
  depsSha256 = "1w8gq9f3mzm52l4ymwxvjs2xcz3ngbh37cxih9ckpays9w3kb9ws";

  meta = with stdenv.lib; {
    description = "Component: Aggregate the triples from all the chunks such that
   input: (airline, 2000, 3), (airline, 3000, 5), (airline, 2000, 8)
   output: (airline, 2000, 11) (airline, 3000, 5)
   where a triple is (type, price, user_count)";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/aggregate_triple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
