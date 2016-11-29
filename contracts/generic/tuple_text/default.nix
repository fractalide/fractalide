{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xe4d61f4e36da94a1;

    struct GenericTupleText {
      key @0 :Text;
      value @1 :Text;
    }
  '';
}
