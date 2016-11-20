{stdenv, buildFractalideContract, upkeepers
  , tuple
  , ...}:

buildFractalideContract rec {
  src = ./.;
  importedContracts = [ tuple ];
  contract = ''
  @0xf698d2e1249dada8;
  using Tuple = import "${tuple}/src/contract.capnp";

  struct ListTuple {
      tuples @0 : List(Tuple.Tuple);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a list of triples";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/triple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
