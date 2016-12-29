{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x8d9b4c3b4a5fba52;

    struct PrimU64 {
            u64 @0 :UInt64;
    }
  '';
}
