{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimU8 {
            u8 @0 :UInt8;
    }
  '';
}
