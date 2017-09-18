{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimU32 {
            u32 @0 :UInt32;
    }
  '';
}
