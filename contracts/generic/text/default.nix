{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xb1fc090ed4d12aee;

  struct GenericText {
          text @0 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple text field";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/generic/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
