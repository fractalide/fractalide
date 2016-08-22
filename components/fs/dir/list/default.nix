{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path ];
  depsSha256 = "06h9b86bwan2bcp9z9331fff4dhnsbldbb4gmrcf89jgnpi1cdzw";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
