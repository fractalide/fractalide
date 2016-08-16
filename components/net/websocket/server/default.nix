{ stdenv, buildFractalideComponent, genName, upkeepers
  , protocol_domain_port
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ protocol_domain_port ];
  depsSha256 = "148238b2nlbiv370v4bacvqjk8v4p789pxy10qnfyr543yb68az0";

  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
