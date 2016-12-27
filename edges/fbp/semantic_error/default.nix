{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text list_prim_text ];
  schema = with edges; ''
    @0xf96c29a52799b766;

    using PrimText = import "${prim_text}/src/edge.capnp";
    using ListPrimText = import "${list_prim_text}/src/edge.capnp";

    struct FbpSemanticError {
      path @0 :PrimText.PrimText;
      parsing @1 :ListPrimText.ListPrimText;
    }
  '';
}
