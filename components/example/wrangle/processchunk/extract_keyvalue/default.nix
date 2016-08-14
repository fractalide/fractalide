{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_tuple
  , list_triple
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_tuple list_triple value_string];
  depsSha256 = "0y23qmikbbbfwpr71xkqmr56531sjqy1f3xm4i0a6caccx9di131";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors, one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
