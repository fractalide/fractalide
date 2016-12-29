{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_tuple_tb ];
  schema = with edges; ''
    @0xe41c98af42a5fc19;

    using NtupTupleTb = import "${ntup_tuple_tb}/src/edge.capnp";

    struct NtupListTupleTb {
      list @0 : List(NtupTupleTb.NtupTupleTb);
    }
  '';
}
