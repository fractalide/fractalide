{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [ tuple ];
  schema = with contracts; ''
    @0xf698d2e1249dada8;
    using Tuple = import "${tuple}/src/contract.capnp";

    struct ListTuple {
        tuples @0 : List(Tuple.Tuple);
    }
  '';
}
