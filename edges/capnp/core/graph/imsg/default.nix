{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreGraphImsg {
           imsg @0 :Text;
           comp @1 :Text;
           port @2 :Text;
           selection @3 :Text;
    }

  '';
}
