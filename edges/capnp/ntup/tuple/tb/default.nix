{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ PrimText PrimBool ];
  schema = with edges.capnp; ''
    struct NtupTupleTb {
      first @0 : PrimText;
      second @1 : PrimBool;
    }
  '';
}
