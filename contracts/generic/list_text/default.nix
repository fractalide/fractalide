{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xd1376f2c4c24bf8b;

  struct GenericListText {
          listText @0 :List(Text);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple list with text elements";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/generic/list_text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
