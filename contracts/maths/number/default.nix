{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xbde554c96bf60f25;

  struct MathsNumber {
    number @0 :Int64;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple Int64 data type";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/maths/number;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
