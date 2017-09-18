{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreActionSend {
           comp @0 :Text;
           port @1 :Text;
           selection @2 :Text;
    }
  '';
}
