{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    struct KvKeyTValT {
        key @0 :PrimText;
        val @1 :PrimText;
    }
  '';
}
