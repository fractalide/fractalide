{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [ command ];
  schema = with contracts; ''
    @0xf61e7fcd2b18d862;
    using Command = import "${command}/src/contract.capnp";

    struct ListCommand {
        commands @0 :List(Command.Command);
    }
  '';
}
