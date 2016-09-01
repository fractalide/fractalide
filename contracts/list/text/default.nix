{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xa3cd85e8335a7357;

  struct ListText {
          texts @0 :List(Text);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple list with text elements";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
