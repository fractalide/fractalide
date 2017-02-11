{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimI32 {
            i32 @0 :Int32;
    }
  '';
}
