{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , net_ndn_data
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest net_ndn_data ];
  depsSha256 = "0fwjy0a686l3hsljzsdd46dggwgsdn0yrnrzdm9hah5gywsp9d4v";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Content Store";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/cs;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
