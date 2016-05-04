{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["value_string" "list_tuple"];
  depsSha256 = "0pjdnk4188zb3627y376c551bkw3ray5h6f6wpxanb62648gkkv1";

  meta = with stdenv.lib; {
    description = "Component: convert each JSON file into a vector of tuples";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/convert_json_vector;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
