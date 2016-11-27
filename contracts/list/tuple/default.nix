{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xf698d2e1249dada8;
    using Tuple = import "${tuple}/src/contract.capnp";

    struct ListTuple {
        tuples @0 : List(Tuple.Tuple);
    }
  '';
}
