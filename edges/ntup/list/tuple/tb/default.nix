{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ NtupTupleTb ];
  schema = with edges; ''
    struct NtupListTupleTb {
      list @0 : List(NtupTupleTb);
    }
  '';
}
