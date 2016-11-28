{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0x87496148360d604f;

    struct GenericBool {
            bool @0 :Bool;
    }
  '';
}
