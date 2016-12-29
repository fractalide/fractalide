{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xb20e72f38015e711;

    struct PrimF64 {
            f64 @0 :Float64;
    }
  '';
}
