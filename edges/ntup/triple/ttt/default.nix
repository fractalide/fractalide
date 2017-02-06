{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimText ];
  schema = with edges; ''
    struct NtupTripleTtt {
      first @0 : PrimText;
      second @1 : PrimText;
      third @2 : PrimText;
    }
  '';
}
