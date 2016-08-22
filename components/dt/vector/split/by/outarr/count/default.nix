{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list ];
  depsSha256 = "19lfayd5sclmi9xc9rzl505ja29lpzgmskka9w26jj416cyj5vc0";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
