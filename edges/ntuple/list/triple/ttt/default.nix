{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntuple_triple_ttt ];
  schema = with edges; ''
    @0xe10bbdb0e95c0c78;

    using NtupleTripleTtt = import "${ntuple_triple_ttt}/src/edge.capnp";

    struct NtupleListTripleTtt {
      list @0 : List(NtupleTripleTtt.NtupleTripleTtt);
    }
  '';
}
