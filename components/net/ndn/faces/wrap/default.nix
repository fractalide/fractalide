{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "1l75psvnbyrpq3blbsj37mk7gby91zfimh516vghs75jb4y6h3li";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Face";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/faces/wrap;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
