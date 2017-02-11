{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimText PrimBool ];
  schema = with edges; ''
    struct NtupTupleTb {
      first @0 : PrimText;
      second @1 : PrimBool;
    }
  '';
}
