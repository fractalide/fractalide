{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntuple_tuple_tb ];
  schema = with edges; ''
    @0xe41c98af42a5fc19;

    using NtupleTupleTb = import "${ntuple_tuple_tb}/src/edge.capnp";

    struct ListNtupleTupleTb {
      list @0 : List(NtupleTupleTb.NtupleTupleTb);
    }
  '';
}
