{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_tuple_tb ];
  schema = with edges; ''
    struct NtupListTupleTb {
      list @0 : List(NtupTupleTb);
    }
  '';
}
