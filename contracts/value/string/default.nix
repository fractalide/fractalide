{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xd9a3ed03c95db4cc;

     struct ValueString {
         value @0 :Text;
     }
  '';
}
