{ stdenv, buildFractalideComponent, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "188n9p40g0camgxkwy05r79xw2s9gpbqlmyi18wnq17a1f2rd87m";

  meta = with stdenv.lib; {
    description = "Component: Drop an Information Packet";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/drop/ip;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
