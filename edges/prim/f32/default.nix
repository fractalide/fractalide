{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xfcc3cc0c82c4e48c;

    struct PrimF32 {
            f32 @0 :Float32;
    }
  '';
}
