{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest ];
  depsSha256 = "06r0ih1flyl72lxhz79kark46kv58szqxiflnx699q2wy95gardj";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
