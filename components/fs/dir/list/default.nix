{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path ];
  depsSha256 = "1xqm5pw8cph55a8q479g99qdbn25zin9hzp1v68pyy4f9f2f1smc";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
