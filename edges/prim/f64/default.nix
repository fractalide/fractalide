{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimF64 {
            f64 @0 :Float64;
    }
  '';
}
