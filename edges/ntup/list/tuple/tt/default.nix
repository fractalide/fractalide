{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_tuple_tt ];
  schema = with edges; ''
    @0xe68275c80cbf654e;

    using NtupTupleTt = import "${ntup_tuple_tt}/src/edge.capnp";

    struct NtupListTupleTt {
      list @0 : List(NtupTupleTt.NtupTupleTt);
    }
  '';
}
