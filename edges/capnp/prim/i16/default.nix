{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimI16 {
            i16 @0 :Int16;
    }
  '';
}
