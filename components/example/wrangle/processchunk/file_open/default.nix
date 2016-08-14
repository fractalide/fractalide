{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string path file_error ];
  depsSha256 = "0zc53smg5dz4xwx01n5aslwzrz9ff8h420gdqr8yyj3875gy651l";

  meta = with stdenv.lib; {
    description = "Component: input: a path, output: a list of filenames";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
