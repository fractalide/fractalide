{ stdenv, buildFractalideComponent, genName, upkeepers
  , js_create
  , generic_tuple_text
  , generic_text
  , generic_bool
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create generic_tuple_text generic_text generic_bool ];
  depsSha256 = "1lzw9aj8fybxf4s9wl4fy3p55khl1bqvqpx9jwif75y4vs2z8k80";

  meta = with stdenv.lib; {
    description = "Component: draw a http tag";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
