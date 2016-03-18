{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_desc" "list_tuple"];
  depsSha256 = "0y6hi3klx3sbcf7way0p57ahnfbhmp9mpji016kjq2cjjarlxj5f";

  meta = with stdenv.lib; {
    description = "Component: convert each JSON file into a vector of tuples";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/convert_json_vector;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
