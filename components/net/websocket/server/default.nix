{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , nanomsg
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  buildInputs = [nanomsg];
  depsSha256 = "0xan0piih1m93h4m4dysvrdv6rnyz8wllb5xkzm3n3pq113sdija";
  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
