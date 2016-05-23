{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "141k9h1n0fczbjsdmflqirll5rr830f7w1a8gqaa75apf70phbvz";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Forwarding Information Base";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/fib;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
