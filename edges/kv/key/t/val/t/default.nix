{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimText ];
  schema = with edges; ''
    struct KvKeyTValT {
        key @0 :PrimText;
        val @1 :PrimText;
    }
  '';
}
