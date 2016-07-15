{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create" "generic_tuple_text" "generic_text" "generic_bool"];
  depsSha256 = "1x9yz6xjp3n5c1izd1sq2qhj47jkxz7lq0zp6qm29y0s9jmr3fsn";

  meta = with stdenv.lib; {
    description = "Component: draw a http tag";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
