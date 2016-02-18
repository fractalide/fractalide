{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["maths_boolean"];
  depsSha256 = "04pdgchvd9pk7zkjdqz75flcpww9rvnhvgz8p0g623ia2fkycyh7";

  meta = with stdenv.lib; {
    description = "Component: Print the content of the contract maths_boolean";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
