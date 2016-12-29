{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_u32 prim_f32 ];
  schema = with edges; ''
    @0xcfac55e5d5e97b4f;

    using PrimU32 = import "${prim_u32}/src/edge.capnp";
    using PrimF32 = import "${prim_f32}/src/edge.capnp";

    struct NtupleQuadrupleU32u32u32f32 {
      first @0 : PrimU32.PrimU32;
      second @1 : PrimU32.PrimU32;
      third @2 : PrimU32.PrimU32;
      fourth @3 : PrimF32.PrimF32;
    }
  '';
}
