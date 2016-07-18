{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" "net_ndn_data" ];
  depsSha256 = "1nkxrvcs4arakj3sp4bl7apna0fy96i7cvppzk4d55ll74547fvf";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Pending Interest Table";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/pit;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
