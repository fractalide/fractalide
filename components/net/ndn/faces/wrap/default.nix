{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "1i89sy6fajs640pjkndal368ic224fj7azghp6qzwgldhcs65j41";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Face";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/faces/wrap;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
