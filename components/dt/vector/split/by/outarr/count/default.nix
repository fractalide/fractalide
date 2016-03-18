{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "file_list" ];
  depsSha256 = "0a1qjxzpzbskzv7qbygxwfkd3ybzz2cldk43nycfa4pnn7lwn57q";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
