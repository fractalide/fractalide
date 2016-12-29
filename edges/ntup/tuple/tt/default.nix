{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xf3ce83ff2d23dbc6;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct NtupTupleTt {
      first @0 : PrimText.PrimText;
      second @1 : PrimText.PrimText;
    }
  '';
}
