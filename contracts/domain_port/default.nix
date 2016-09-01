{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xbb7b3123b414d4bb;

   struct DomainPort {
           domainPort @0 :Text;
   }
  '';
  meta = with stdenv.lib; {
    description = "Contract: Describes a domain and port of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/domain_port;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
