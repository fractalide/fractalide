{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x9d9aba335f70cc13;

    struct PrimU8 {
            u8 @0 :UInt8;
    }
  '';
}
