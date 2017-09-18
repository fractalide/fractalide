{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ NtupTupleTt ];
  schema = with edges.capnp; ''
    struct NtupListTupleTt {
      list @0 : List(NtupTupleTt);
    }
  '';
}
