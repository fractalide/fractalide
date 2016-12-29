{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text prim_list_text ];
  schema = with edges; ''
    @0xf96c29a52799b766;

    using PrimText = import "${prim_text}/src/edge.capnp";
    using PrimListText = import "${prim_list_text}/src/edge.capnp";

    struct CoreSemanticError {
      path @0 :PrimText.PrimText;
      parsing @1 :PrimListText.PrimListText;
    }
  '';
}
