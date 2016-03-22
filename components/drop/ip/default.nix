{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "1k4q163ca5m03kgpzr9lnbpi3vh9arqj3ybh76lban7fvm3pqkr7";
  meta = with stdenv.lib; {
    description = "Component: Drop an Information Packet";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/drop/ip;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
