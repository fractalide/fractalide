{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimI16 {
            i16 @0 :Int16;
    }
  '';
}
