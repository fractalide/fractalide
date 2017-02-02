{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimI8 {
            i8 @0 :Int8;
    }
  '';
}
