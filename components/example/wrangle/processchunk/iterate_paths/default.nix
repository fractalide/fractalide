{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path value_string ];
  depsSha256 = "1gs3x1ydy9grqxp8g7fppi6hnxk05ymdlxg492vd3v7bh4i8glmh";

  meta = with stdenv.lib; {
    description = "Component: Iterate over a list of 1000 file paths";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangler/iterate_paths;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
