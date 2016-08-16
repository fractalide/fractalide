{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text generic_tuple_text ];
  depsSha256 = "0r214sb6xv5rbkjhxl5ipc4ywhrk00vl9nwnhravh5nn24p4p93c";

  meta = with stdenv.lib; {
    description = "Component: filter enter and escape keyup";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
