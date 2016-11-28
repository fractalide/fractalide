{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [ command ];
  schema = with contracts; ''
    @0xafd2d34a29d48dbd;
    using Command = import "${command}/src/contract.capnp";

    struct ShellCommands {
      commands @0 :List(Command.Command);
    }
  '';
}
