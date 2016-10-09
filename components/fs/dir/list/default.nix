{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path ];
  depsSha256 = "1cq3s60x7nkspsbggkg283svjkgcry104cw41ylc6fs4zxq3zdj8";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
