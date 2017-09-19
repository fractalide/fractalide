{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreActionConnectSender {
           name @0 :Text;
           port @1 :Text;
           selection @2 :Text;
           output @3 :Text;
    }

  '';
}
