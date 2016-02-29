{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["maths_number"];
  depsSha256 = "1c3xn618k0z05hv2hng9ds05x3hlw5ywin7ip4yr3xs7i459jrzp";

  meta = with stdenv.lib; {
    description = "Component: Adds all inputs together";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/add;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
