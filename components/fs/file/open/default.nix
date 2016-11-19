{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc path file_error ];
  depsSha256 = "1cq1bbrpznzkawi9pxpigxh5ykxrc427a43mrjg8dc636hxklvnk";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
