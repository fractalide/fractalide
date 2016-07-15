{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "0d0a11s51d35m6xy460bqdl3ar1vgwj7lzb1jgy0qg55liawb3hc";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
