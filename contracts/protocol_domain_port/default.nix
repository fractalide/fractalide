{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xd41e6861b9d35c4b;

   struct ProtocolDomainPort {
           protocol @0 :Text;
           domain @1 :Text;
           port @2 :UInt32;
   }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes the protocol, domain and port of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/protocol_domain_port;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
