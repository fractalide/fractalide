{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ NtupTupleTt ];
  schema = with edges; ''
    struct NtupListTupleTt {
      list @0 : List(NtupTupleTt);
    }
  '';
}
