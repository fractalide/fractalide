{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0x8c9f81d7489d6d29;

     struct Url {
             url @0 :Text;
     }
  '';
}
