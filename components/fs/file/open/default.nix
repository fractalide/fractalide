{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_desc
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_desc path file_error ];
  depsSha256 = "012izwq745id0gm18qlcd6bkm6j1qdw3lbym8svnzp2yglhfyyq1";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
