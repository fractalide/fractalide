{stdenv, buildFractalideContract, upkeepers
  , command
  , ...}:

buildFractalideContract rec {
  src = ./.;
  importedContracts = [ command ];
  contract = ''
  @0xf61e7fcd2b18d862;
  using Command = import "${command}/src/contract.capnp";

  struct ListCommand {
      commands @0 :List(Command.Command);
  }
  '';
  meta = with stdenv.lib; {
    description = "Contract: Describes a list of commands";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/list/commands;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
