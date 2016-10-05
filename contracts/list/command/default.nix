{stdenv, buildFractalideContract, upkeepers
  , ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xf61e7fcd2b18d862;

    struct Tuple {
      first @0 : Text;
      second @1 : Text;
    }

    struct Command {
      name @0 : Text;
      singles @1 : List(Text);
      kvs @2 : List(Tuple);
    }

    struct ListCommand {
        commands @0 :List(Command);
    }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a list of commands";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/commands;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
