{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimI64 PrimText ];
  schema = with edges; ''
    struct KvKeyTValueI64 {
        key @0 :PrimText;
        value @1 :PrimI64;
    }
  '';
}
