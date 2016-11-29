{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0x86b82a2fc79a7f6d;

    struct AppCounter {
      value @0 :Int64;
      delta @1 :Int64 = 1;
    }
  '';
}
