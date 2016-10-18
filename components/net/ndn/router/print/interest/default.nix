{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest ];
  depsSha256 = "1d8zk5d5mb11hscwvz1mahfam5qk9wwwp0rcdakmkiryifh4yvmq";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
