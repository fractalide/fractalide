{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimU16 {
            u16 @0 :UInt16;
    }
  '';
}
