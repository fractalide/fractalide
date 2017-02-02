{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimI64 {
            i64 @0 :Int64;
    }
  '';
}
