{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct PrimF64 {
            f64 @0 :Float64;
    }
  '';
}
