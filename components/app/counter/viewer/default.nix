{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , app_counter
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text app_counter generic_tuple_text ];
  depsSha256 = "0zimrgfzashq065i4favg6lqh5ji1qmhccx9z6ap8f4damj8dzvw";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
