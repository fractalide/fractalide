{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ PrimI64 PrimText ];
  schema = with edges.capnp; ''
    struct KvKeyTValueI64 {
        key @0 :PrimText;
        value @1 :PrimI64;
    }
  '';
}
