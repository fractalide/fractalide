{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ PrimText ];
  schema = with edges.capnp; ''
    struct NtupTripleTtt {
      first @0 : PrimText;
      second @1 : PrimText;
      third @2 : PrimText;
    }
  '';
}
