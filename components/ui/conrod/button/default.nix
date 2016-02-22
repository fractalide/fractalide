{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "0lijccynfvv4z05m35mnwaxd0arinlpy2qbmscayf5hk7c87nx8b";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod button";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
