{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string path file_error ];
  depsSha256 = "1dd93151vnvdcn23w3z22aac5f5zv1xai3a9ijjqfzbbwla0r5hx";

  meta = with stdenv.lib; {
    description = "Component: input: a path, output: a list of filenames";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
