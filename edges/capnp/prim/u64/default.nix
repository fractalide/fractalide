{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimU64 {
            u64 @0 :UInt64;
    }
  '';
}
