{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "1ngx3bs8r4gf78lvpn6xb2n19ypk6zd8almbxkrv6lb5l01wsyj6";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
