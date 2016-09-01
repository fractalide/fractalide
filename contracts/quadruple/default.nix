{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xcfac55e5d5e97b4f;

  struct Quadruple {
    first @0 : UInt32;
    second @1 : UInt32;
    third @2 : UInt32;
    fourth @3 : Float32;
  }
  '';
  meta = with stdenv.lib; {
    description = "Contract: Describes a quadruple";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/quadruple;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
