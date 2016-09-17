{stdenv, buildFractalideContract, upkeepers
  , list_text
  , ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xf61e7fcd2b18d862;

  struct List1 {
          texts @0 :List(Text);
  }

  struct List0 {
          list @0 :List(List1);
  }

  struct ListListListText {
          list @0 :List(List0);
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a list of a list, of a list containing text elements";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
