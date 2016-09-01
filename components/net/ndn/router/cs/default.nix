{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , net_ndn_data
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest net_ndn_data ];
  depsSha256 = "170b2xrv6fvfzqnafq9mwjvwm2pf2ps7l27nvsdq3h203b4hh5yj";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Content Store";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/cs;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
