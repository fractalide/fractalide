{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xc5c23ce1a149964f;

    struct PrimU16 {
            u16 @0 :UInt16;
    }
  '';
}
