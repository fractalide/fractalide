{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xdcafadeae5197229;

    struct PrimU32 {
            u32 @0 :UInt32;
    }
  '';
}
