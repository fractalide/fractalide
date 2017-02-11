{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimF32 {
            f32 @0 :Float32;
    }
  '';
}
