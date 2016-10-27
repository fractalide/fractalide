{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path ];
  depsSha256 = "1476qbg0d8a3qn5jr4l8hwqx16xi6mnjfh5rhzzlhfw0wyzkpags";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
