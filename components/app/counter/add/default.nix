{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ app_counter ];
  depsSha256 = "0r214sb6xv5rbkjhxl5ipc4ywhrk00vl9nwnhravh5nn24p4p93c";

  meta = with stdenv.lib; {
    description = "Component: increase by one the number";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
