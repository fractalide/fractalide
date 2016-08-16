{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest ];
  depsSha256 = "1nn18wg4r8i1yzvksiipblk9lxxnngzi4ig8iidd94yshjc6z7bj";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Forwarding Information Base";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/fib;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
