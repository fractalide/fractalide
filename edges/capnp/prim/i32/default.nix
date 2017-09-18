{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimI32 {
            i32 @0 :Int32;
    }
  '';
}
