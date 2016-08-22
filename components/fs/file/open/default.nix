{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc path file_error ];
  depsSha256 = "0i90ax1wlsfq0r117grvm6jizdyrz6qnljxj7jqgn3v9jwdcgd8h";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
