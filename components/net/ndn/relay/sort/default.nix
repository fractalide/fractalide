{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , net_ndn_data
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest net_ndn_data];
  depsSha256 = "0d910j7zixbyd6qy1bq5npv81rd7p1z46vm2v2c5w444wp2c50kz";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Forwarding Information Base";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/fib;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
