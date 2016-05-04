{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "0jbzpbff7kadxl1k06nyg4pkifg3yij6r00nshy91zxf00li6a6w";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Face";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/face;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
