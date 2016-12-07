{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ command ];
  schema = with edges; ''
    @0xf61e7fcd2b18d862;
    using Command = import "${command}/src/edge.capnp";

    struct ListCommand {
        commands @0 :List(Command.Command);
    }
  '';
}
