{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [ ];
  schema = with contracts; ''
    @0xbb7b3123b414d4bb;

     struct DomainPort {
             domainPort @0 :Text;
     }
  '';
}
