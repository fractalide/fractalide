{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xbde554c96bf60f36;

  struct MathsBoolean {
    boolean @0 :Bool;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple boolean data type";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/maths/boolean;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
