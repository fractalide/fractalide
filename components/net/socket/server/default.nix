{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , nanomsg
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  buildInputs = [nanomsg];
  depsSha256 = "00570xwsj2jhv68yh2mn2f0pdlclba9mw91s7hn6zkrq7xm4bsi3";
  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
