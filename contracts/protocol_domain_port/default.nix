{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Contract: Describes the protocol, domain and port of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/protocol_domain_port;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
