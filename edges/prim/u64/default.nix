{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimU64 {
            u64 @0 :UInt64;
    }
  '';
}
