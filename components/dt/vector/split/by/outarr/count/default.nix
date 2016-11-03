{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list ];
  depsSha256 = "1wly6jpamn1q3jqn970bia9gi0pzsg4gsk3bx3msq9yz368v3gyg";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
