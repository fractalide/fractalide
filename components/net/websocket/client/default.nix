{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  depsSha256 = "1s1msb5cjpn7cx8jz72kyzcka3pzwdmvcp37mgg3dys1z4vmpwpw";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
