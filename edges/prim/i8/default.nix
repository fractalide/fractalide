{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x952473e6e0df4da8;

    struct PrimI8 {
            i8 @0 :Int8;
    }
  '';
}
