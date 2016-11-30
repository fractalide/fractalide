{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xd41e6861b9d35c4b;

     struct ProtocolDomainPort {
             protocol @0 :Text;
             domain @1 :Text;
             port @2 :UInt32;
     }
  '';
}
