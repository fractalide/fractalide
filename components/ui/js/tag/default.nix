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
  depsSha256 = "1mhvp4i5n4c7dma6lp9m2cjpjp4cqblrya4di1y857ydk6bsj7yz";

  meta = with stdenv.lib; {
    description = "Component: draw a http tag";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
