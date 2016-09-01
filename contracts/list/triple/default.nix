{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
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

  meta = with stdenv.lib; {
    description = "Contract: Describes a list of triples";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/triple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
