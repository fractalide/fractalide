{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text prim_bool ];
  schema = with edges; ''
    struct NtupTupleTb {
      first @0 : PrimText;
      second @1 : PrimBool;
    }
  '';
}
