{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create"];
  depsSha256 = "0wpz03wza7yqa7gbj86gs0wg63n312bnlfzn7br3f9qlbs2c66dv";
  meta = with stdenv.lib; {
    description = "Component: draw a place holder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
