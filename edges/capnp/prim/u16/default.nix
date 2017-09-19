{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimU16 {
            u16 @0 :UInt16;
    }
  '';
}
