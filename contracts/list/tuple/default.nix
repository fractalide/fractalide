{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xf698d2e1249dada8;

  struct Tuple {
    first @0 : Text;
    second @1 : Text;
  }

  struct ListTuple {
      tuples @0 : List(Tuple);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a list of triples";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/triple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
