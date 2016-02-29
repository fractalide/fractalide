{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "0l2w3p24s7c82iw36vrckqlr0l8y23pq80rbnf8kg6aikrrk9zpl";

  meta = with stdenv.lib; {
    description = "Component: dispatch the action to the output selection";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
