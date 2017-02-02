{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_i64 prim_text ];
  schema = with edges; ''
    struct KvKeyTValueI64 {
        key @0 :PrimText;
        value @1 :PrimI64;
    }
  '';
}
