{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest ];
  depsSha256 = "1daff8l6z5cmy6lpsbvm8m5m2435jc7ihi2p12mdhqnxf31kcbin";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
