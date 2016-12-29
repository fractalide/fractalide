{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntuple_tuple_tt ];
  schema = with edges; ''
    @0xe68275c80cbf654e;

    using NtupleTupleTt = import "${ntuple_tuple_tt}/src/edge.capnp";

    struct NtupleListTupleTt {
      list @0 : List(NtupleTupleTt.NtupleTupleTt);
    }
  '';
}
