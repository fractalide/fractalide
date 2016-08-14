{ stdenv, buildFractalideComponent, genName, upkeepers
  , protocol_domain_port
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ protocol_domain_port ];
  depsSha256 = "1wj5630x1kc5kbnb4504m7iv5387c7gvxmrlcnpf85s302gjz453";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
