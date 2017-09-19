{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ NtupTripleTtt ];
  schema = with edges.capnp; ''
    struct NtupListTripleTtt {
      list @0 : List(NtupTripleTtt);
    }
  '';
}
