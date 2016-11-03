{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x8bb5b850bcfc82e6;

  struct NetHttpAddress {
    address @0 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple net address";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/maths/boolean;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
