{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [ tuple ];
  schema = with contracts; ''
    @0xdfa17455eb3bee21;
    using Tuple = import "${tuple}/src/contract.capnp";

    struct Command {
      name @0 : Text;
      singles @1 : List(Text);
      kvs @2 : List(Tuple.Tuple);
      iips @3 : List(Text);
    }
  '';
}
