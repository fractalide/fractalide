{ stdenv, buildFractalideComponent, genName, upkeepers
  , protocol_domain_port
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ protocol_domain_port ];
  depsSha256 = "1il5932xp1q5z25ajdrhnbghx3qhlkvr19j3b4pdkvsnyxbvcadr";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
