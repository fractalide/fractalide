{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" "net_ndn_data" ];
  depsSha256 = "1g2d97lla963sczp49q6kg7cc9zxkhs78c3665krhqr78skaf7m0";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Content Store";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/cs;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
