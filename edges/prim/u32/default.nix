{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimU32 {
            u32 @0 :UInt32;
    }
  '';
}
