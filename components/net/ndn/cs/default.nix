{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" "net_ndn_data" ];
  depsSha256 = "0rqvgng8cqrim1fqm8hhlrzc5w3b08vp702ifvlg8bynnd25wass";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Content Store";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/cs;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
