{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimText ];
  schema = with edges; ''
    struct NtupTupleTt {
      first @0 : PrimText;
      second @1 : PrimText;
    }
  '';
}
