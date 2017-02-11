{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimU8 {
            u8 @0 :UInt8;
    }
  '';
}
