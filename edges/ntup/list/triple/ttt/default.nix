{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_triple_ttt ];
  schema = with edges; ''
    @0xe10bbdb0e95c0c78;

    using NtupTripleTtt = import "${ntup_triple_ttt}/src/edge.capnp";

    struct NtupListTripleTtt {
      list @0 : List(NtupTripleTtt.NtupTripleTtt);
    }
  '';
}
