{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimF32 {
            f32 @0 :Float32;
    }
  '';
}
