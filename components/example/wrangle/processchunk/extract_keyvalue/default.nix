{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "list_tuple" "list_triple" "value_string"];
  depsSha256 = "1m7wrn4akpw9ah6h48x9i3a4zxrd0wvsxr7zai61d41fg8inphc4";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors, one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
