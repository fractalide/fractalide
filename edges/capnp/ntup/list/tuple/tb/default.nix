{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ NtupTupleTb ];
  schema = with edges.capnp; ''
    struct NtupListTupleTb {
      list @0 : List(NtupTupleTb);
    }
  '';
}
