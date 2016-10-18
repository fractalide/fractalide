{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path ];
  depsSha256 = "1d13wv4n1pf1znbp3rjzypqd3k9whr3vpv3jyywqfd6lnl6rvb8p";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
