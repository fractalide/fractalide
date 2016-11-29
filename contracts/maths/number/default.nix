{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xbde554c96bf60f25;

    struct MathsNumber {
      number @0 :Int64;
    }
  '';
}
