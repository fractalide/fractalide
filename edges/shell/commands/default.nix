{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ command ];
  schema = with edges; ''
    @0xafd2d34a29d48dbd;
    using Command = import "${command}/src/edge.capnp";

    struct ShellCommands {
      commands @0 :List(Command.Command);
    }
  '';
}
