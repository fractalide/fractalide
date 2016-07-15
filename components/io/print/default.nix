{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text"];
  depsSha256 = "1qsjxmj6hwjjqjl59wwhqfwvjrxb06svma157jwxwjf9z2pz79n3";

  meta = with stdenv.lib; {
    description = "Component: Print to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
