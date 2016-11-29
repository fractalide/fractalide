{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xb1fc090ed4d12aee;

    struct GenericText {
            text @0 :Text;
    }
  '';
}
