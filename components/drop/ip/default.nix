{ stdenv, buildFractalideComponent, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "0b6r4d3jskxy7hmn4cqj09z77hp21l907y4df3zrhch7i3s2vfm4";

  meta = with stdenv.lib; {
    description = "Component: Drop an Information Packet";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/drop/ip;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
