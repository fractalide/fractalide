{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list ];
  depsSha256 = "16blkbv4qy7ky5fn9db60pvrz6iddhrn47g33ga7ky59ivwjlsmw";

  meta = with stdenv.lib; {
    description = "Component: Split a vector into multiple vectors one for each element in the output array port";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/dt/vector/split/by/outarr/count;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
