{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xdc32f51a96b92f41;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct NtupTripleTtt {
      first @0 : PrimText.PrimText;
      second @1 : PrimText.PrimText;
      third @2 : PrimText.PrimText;
    }
  '';
}
