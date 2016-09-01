{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xafd2d34a29d48dbd;

  struct ShellCommands {
    commands @0 :List(Command);
  }

  struct Command {
         key @0 :Text;
         val @1 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Mappings used to convert a complex hierarchical name such as 'shell_commands_cd' to 'cd'.";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/shells/commands;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
