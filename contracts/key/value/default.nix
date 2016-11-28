{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0x8a258ed34eb0c0bb;

    struct KeyValue {
        key @0 :Text;
        value @1 :Int64;
    }
  '';
}
