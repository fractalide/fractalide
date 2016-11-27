{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xd9a3ed03c95db4cc;

     struct ValueInt64 {
         value @0 :Text;
     }
  '';
}
