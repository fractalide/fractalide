{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ PrimU32 PrimF32 ];
  schema = with edges.capnp; ''
    struct NtupQuadrupleU32u32u32f32 {
      first @0 : PrimU32;
      second @1 : PrimU32;
      third @2 : PrimU32;
      fourth @3 : PrimF32;
    }
  '';
}
