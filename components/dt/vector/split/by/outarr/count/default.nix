{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "file_list" ];
  depsSha256 = "0kz497i531glpavkk71l8qmx9g8a7vds83qvn25bbrfcq5xpadxj";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
