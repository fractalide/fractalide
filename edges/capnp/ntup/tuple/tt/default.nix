{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ PrimText ];
  schema = with edges.capnp; ''
    struct NtupTupleTt {
      first @0 : PrimText;
      second @1 : PrimText;
    }
  '';
}
