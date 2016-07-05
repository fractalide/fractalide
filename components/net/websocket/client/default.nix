{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  depsSha256 = "0ag7xmkdwxiagj2h7sb2gcrhlxymq36g6gd3ihcv0q5dd5hz0wmh";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
