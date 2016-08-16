{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , path
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string path file_error ];
  depsSha256 = "14yanjca9wh9fp5bq7qswlzhk839fyrqwn1gbfl5qkx3f0h122pl";

  meta = with stdenv.lib; {
    description = "Component: input: a path, output: a list of filenames";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
