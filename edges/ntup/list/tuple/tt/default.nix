{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_tuple_tt ];
  schema = with edges; ''
    struct NtupListTupleTt {
      list @0 : List(NtupTupleTt);
    }
  '';
}
