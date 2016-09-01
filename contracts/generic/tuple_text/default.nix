{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xe4d61f4e36da94a1;

  struct GenericTupleText {
    key @0 :Text;
    value @1 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple list with text elements";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/generic/list_text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
