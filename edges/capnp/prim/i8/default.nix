{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimI8 {
            i8 @0 :Int8;
    }
  '';
}
