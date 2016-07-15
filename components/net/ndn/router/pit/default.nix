{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" "net_ndn_data" ];
  depsSha256 = "1mbrjnas57yq2m886sjda6ich8c8x8j6kb254qglvwiy2bb78h2a";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Pending Interest Table";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/pit;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
