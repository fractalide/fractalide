{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string path file_error ];
  depsSha256 = "11whm9fhzj6qc0i4r824695binz5778ccl133cazq6gncbifas7v";

  meta = with stdenv.lib; {
    description = "Component: input: a path, output: a list of filenames";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
