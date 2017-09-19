{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ PrimText ];
  schema = with edges.capnp; ''
    struct PrimListText {
            list @0 :List(PrimText);
    }
  '';
}
