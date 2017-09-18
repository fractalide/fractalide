{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ PrimText ];
  schema = with edges.capnp; ''
    struct KvKeyTValT {
        key @0 :PrimText;
        val @1 :PrimText;
    }
  '';
}
