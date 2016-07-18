{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" "net_ndn_data" ];
  depsSha256 = "1vpdqsjdm313wnb2kd0975zjgjps2ib18g0dz23sq4al21irygss";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Pending Interest Table";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/pit;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
