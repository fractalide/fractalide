{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest ];
  depsSha256 = "1x5vvavmpxw060zhlbx657za9qnmcjsjkq1sn5h9vjxsll3mg37p";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Forwarding Information Base";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/fib;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
