{ stdenv, buildFractalideComponent, genName, upkeepers
  , protocol_domain_port
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ protocol_domain_port ];
  depsSha256 = "1iallh49lq57jw5jh1s4jwww418608c59ww3daha1310pj5hlm8z";

  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
