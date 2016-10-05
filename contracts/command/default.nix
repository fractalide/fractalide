{stdenv, buildFractalideContract, upkeepers
  , tuple
  , ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xdfa17455eb3bee21;

    struct Tuple {
      first @0 : Text;
      second @1 : Text;
    }

    struct Command {
      name @0 : Text;
      singles @1 : List(Text);
      kvs @2 : List(Tuple);
    }
  '';

  meta = with stdenv.lib; {
    description = "Contract: A Command";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/commands;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
