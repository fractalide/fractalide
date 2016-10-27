{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list ];
  depsSha256 = "17n5hsamhdcii5v17h7y0glcyx9lpf837phc2ijkxqv1w4y2x4w7";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
