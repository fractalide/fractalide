{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xead0a4924cb99ffa;

    struct Triple {
      first @0 : Text;
      second @1 : Text;
      third @2 : Text;
    }

    struct ListTriple {
        triples @0 :List(Triple);
    }
  '';
}
