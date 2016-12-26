{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_i64 prim_text ];
  schema = with edges; ''
    @0xa9fd8346c9942071;

    using PrimI64 = import "${prim_i64}/src/edge.capnp";
    using PrimText = import "${prim_text}/src/edge.capnp";

    struct KeyTValueI64 {
        key @0 :PrimText.PrimText;
        value @1 :PrimI64.PrimI64;
    }
  '';
}
