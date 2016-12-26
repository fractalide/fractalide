{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xfd5b681b05086f3b;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct KeyTValT {
        key @0 :PrimText.PrimText;
        val @1 :PrimText.PrimText;
    }
  '';
}
