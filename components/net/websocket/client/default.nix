{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  depsSha256 = "0cszm3py18g6aypmn4imly96m9130ypsqx2xwj0djpv49sscwwpg";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
